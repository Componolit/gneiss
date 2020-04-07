
with Gneiss.Broker.Lookup;
with Gneiss.Packet;
with Gneiss_Log;
with Gneiss_Internal;

package body Gneiss.Broker.Message with
   SPARK_Mode
is

   function Image (V : RFLX.Session.Kind_Type) return String is
      (case V is
         when RFLX.Session.Message => "Message",
         when RFLX.Session.Log     => "Log",
         when RFLX.Session.Memory  => "Memory",
         when RFLX.Session.Rom     => "Rom",
         when RFLX.Session.Timer   => "Timer");

   procedure Setup_Service (State : in out Service_List;
                            Kind  :        RFLX.Session.Kind_Type;
                            Efd   :        Gneiss_Epoll.Epoll_Fd;
                            Valid :    out Boolean) with
      Pre  => Gneiss_Epoll.Valid_Fd (Efd),
      Post => (if Valid then (State (Kind).Broker > -1 and then State (Kind).Disp > -1));

   procedure Setup_Service (State : in out Service_List;
                            Kind  :        RFLX.Session.Kind_Type;
                            Efd   :        Gneiss_Epoll.Epoll_Fd;
                            Valid :    out Boolean)
   is
      Success : Integer;
   begin
      Valid := False;
      if State (Kind).Broker > -1 and then State (Kind).Disp > -1 then
         Valid := True;
         return;
      end if;
      Gneiss_Syscall.Socketpair (State (Kind).Broker, State (Kind).Disp);
      if State (Kind).Broker < 0 or else State (Kind).Disp < 0 then
         Gneiss_Log.Error ("Failed to create service fds");
         Gneiss_Syscall.Close (State (Kind).Broker);
         Gneiss_Syscall.Close (State (Kind).Disp);
         return;
      end if;
      Gneiss_Epoll.Add (Efd, State (Kind).Broker, State (Kind).Broker, Success);
      if Success /= 0 then
         Gneiss_Log.Error ("Failed to register broker callback");
         Gneiss_Syscall.Close (State (Kind).Broker);
         Gneiss_Syscall.Close (State (Kind).Disp);
         return;
      end if;
      Valid := True;
   end Setup_Service;

   function Convert_Message (S : String) return RFLX_String
   is
      R : RFLX_String (1 .. RFLX.Session.Length_Type (S'Length));
   begin
      for I in R'Range loop
         R (I) := S (S'First + Natural (I - R'First));
      end loop;
      return R;
   end Convert_Message;

   procedure Read_Message (State    : in out Broker_State;
                           Index    :        Positive;
                           Filedesc :        Integer)
   is
      Fds : Gneiss_Syscall.Fd_Array (1 .. 4);
      Msg : Packet.Message;
   begin
      Packet.Receive (Filedesc, Msg, Fds, False);
      if not Msg.Valid then
         Gneiss_Log.Warning ("Invalid message, dropping");
         pragma Warnings (Off, "unused assignment to ""Fd""");
         for Fd of Fds loop
            if Fd > -1 then
               Gneiss_Syscall.Close (Fd);
            end if;
         end loop;
         pragma Warnings (On, "unused assignment to ""Fd""");
         return;
      end if;
      Handle_Message (State, Index,
                      Msg.Action,
                      Msg.Kind,
                      Msg.Name.Value (Msg.Name.Value'First .. Msg.Name.Last),
                      Msg.Label.Value (Msg.Label.Value'First .. Msg.Label.Last),
                      Fds);
   end Read_Message;

   procedure Handle_Message (State  : in out Broker_State;
                             Source :        Positive;
                             Action :        RFLX.Session.Action_Type;
                             Kind   :        RFLX.Session.Kind_Type;
                             Name   :        String;
                             Label  :        String;
                             Fds    :        Gneiss_Syscall.Fd_Array)
   is
   begin
      case Action is
         when RFLX.Session.Request =>
            if Label'Length >= 256 then
               Gneiss_Log.Warning ("Cannot process request");
               return;
            end if;
            Process_Request (State, Source, Kind, Label, Fds);
         when RFLX.Session.Confirm =>
            if Name'Length + Label'Length >= 256 then
               Gneiss_Log.Warning ("Cannot process confirm");
               return;
            end if;
            Process_Confirm (State, Kind, Name, Label, Fds);
         when RFLX.Session.Reject =>
            if Name'Length + Label'Length >= 256 then
               Gneiss_Log.Warning ("Cannot process reject");
               return;
            end if;
            Process_Reject (State, Kind, Name, Label);
         when RFLX.Session.Register =>
            Process_Register (State, Source, Kind);
      end case;
   end Handle_Message;

   procedure Process_Request (State  : in out Broker_State;
                              Source :        Positive;
                              Kind   :        RFLX.Session.Kind_Type;
                              Label  :        String;
                              Fds    :        Gneiss_Syscall.Fd_Array)
   is
      use type SXML.Query.State_Type;
      Serv_State  : SXML.Query.State_Type;
      Destination : Integer;
      Valid       : Boolean;
      Source_Name : String (1 .. 255);
      Last        : Natural;
      Result      : SXML.Result_Type;
      Fds_Out     : Gneiss_Syscall.Fd_Array (1 .. 4);
   begin
      if State.Components (Source).Fd < 0 then
         Gneiss_Log.Warning ("Cannot process invalid source");
         return;
      end if;
      Lookup.Match_Service (State.Xml, State.Components (Source).Node, Image (Kind), Label, Serv_State);
      if Serv_State = SXML.Query.Invalid_State or else not SXML.Query.Is_Open (Serv_State, State.Xml) then
         Gneiss_Log.Error ("No service found");
         Send_Reject (State.Components (Source).Fd, Kind, Label);
         return;
      end if;
      Lookup.Lookup_Request (State, Kind, Serv_State, Destination, Valid);
      if not Valid then
         Gneiss_Log.Error ("No service provider found");
         Send_Reject (State.Components (Source).Fd, Kind, Label);
         return;
      end if;
      SXML.Query.Attribute (State.Components (Source).Node, State.Xml, "name", Result, Source_Name, Last);
      if Result /= SXML.Result_OK then
         Gneiss_Log.Error ("Failed to get source name");
         Send_Reject (State.Components (Source).Fd, Kind, Label);
         return;
      end if;
      case Kind is
         when RFLX.Session.Message | RFLX.Session.Log =>
            if Destination not in State.Components'Range then
               Send_Reject (State.Components (Source).Fd, Kind, Label);
               return;
            end if;
            Process_Message_Request (Fds_Out, Valid);
            if not Valid then
               Send_Reject (State.Components (Source).Fd, Kind, Label);
               return;
            end if;
            Setup_Service (State.Components (Destination).Serv, Kind, State.Epoll_Fd, Valid);
            if not Valid then
               for Fd of Fds_Out loop
                  Gneiss_Syscall.Close (Fd);
               end loop;
               Send_Reject (State.Components (Source).Fd, Kind, Label);
               return;
            end if;
            Send_Request (State.Components (Destination).Serv (Kind).Broker,
                          Kind,
                          Source_Name (Source_Name'First .. Last),
                          Label,
                          Fds_Out (Fds_Out'First .. Fds_Out'First + 1));
         when RFLX.Session.Rom =>
            if Destination in State.Components'Range then
               Gneiss_Log.Warning ("Rom server currently not supported");
            else
               Process_Rom_Request (State, Serv_State, Fds_Out, Valid);
               if Valid then
                  Send_Confirm (State.Components (Source).Fd, Kind, Label, Fds_Out (Fds_Out'First .. Fds_Out'First));
               else
                  Send_Reject (State.Components (Source).Fd, Kind, Label);
               end if;
            end if;
         when RFLX.Session.Memory =>
            if Destination not in State.Components'Range or else Fds'Length < 1 then
               Send_Reject (State.Components (Source).Fd, Kind, Label);
               return;
            end if;
            Process_Memory_Request (Fds, Fds_Out, Valid);
            if not Valid then
               Send_Reject (State.Components (Source).Fd, Kind, Label);
               return;
            end if;
            Setup_Service (State.Components (Destination).Serv, Kind, State.Epoll_Fd, Valid);
            if not Valid then
               for Fd of Fds_Out loop
                  Gneiss_Syscall.Close (Fd);
               end loop;
               Send_Reject (State.Components (Source).Fd, Kind, Label);
               return;
            end if;
            Send_Request (State.Components (Destination).Serv (Kind).Broker,
                          Kind,
                          Source_Name (Source_Name'First .. Last),
                          Label,
                          Fds_Out (Fds_Out'First .. Fds_Out'First + 2));
         when RFLX.Session.Timer =>
            Process_Timer_Request (Fds_Out, Valid);
            if Valid then
               Send_Confirm (State.Components (Source).Fd, Kind, Label, Fds_Out (Fds_Out'First .. Fds_Out'First));
            else
               Send_Reject (State.Components (Source).Fd, Kind, Label);
            end if;
      end case;
   end Process_Request;

   procedure Process_Message_Request (Fds   : out Gneiss_Syscall.Fd_Array;
                                      Valid : out Boolean)
   is
      Fd1 : Integer;
      Fd2 : Integer;
   begin
      Fds := (others => -1);
      Gneiss_Syscall.Socketpair (Fd1, Fd2);
      Valid := Fd1 > -1 and then Fd2 > -1;
      if not Valid then
         Gneiss_Syscall.Close (Fd1);
         Gneiss_Syscall.Close (Fd2);
      end if;
      Fds (Fds'First .. Fds'First + 1) := (Fd1, Fd2);
   end Process_Message_Request;

   procedure Process_Memory_Request (Fds_In  :        Gneiss_Syscall.Fd_Array;
                                     Fds_Out :    out Gneiss_Syscall.Fd_Array;
                                     Valid   :    out Boolean)
   is
      Success : Integer;
      Fd1     : Integer;
      Fd2     : Integer;
   begin
      Valid   := False;
      Fds_Out := (others => -1);
      if Fds_In (Fds_In'First) < 0 then
         return;
      end if;
      Fds_Out (Fds_Out'First + 2) := Fds_In (Fds_In'First);
      Gneiss_Syscall.Memfd_Seal (Fds_Out (Fds_Out'First + 2), Success);
      if Success /= 1 then
         Gneiss_Syscall.Close (Fds_Out (Fds_Out'First + 2));
         return;
      end if;
      Gneiss_Syscall.Socketpair (Fd1, Fd2);
      Fds_Out (Fds_Out'First .. Fds_Out'First + 1) := (Fd1, Fd2);
      Valid := Fds_Out (Fds_Out'First) > -1 and then Fds_Out (Fds_Out'First + 1) > -1;
      if not Valid then
         Gneiss_Syscall.Close (Fds_Out (Fds_Out'First));
         Gneiss_Syscall.Close (Fds_Out (Fds_Out'First + 1));
         Gneiss_Syscall.Close (Fds_Out (Fds_Out'First + 2));
      end if;
   end Process_Memory_Request;

   procedure Process_Rom_Request (State       :     Broker_State;
                                  Serv_State  :     SXML.Query.State_Type;
                                  Fds         : out Gneiss_Syscall.Fd_Array;
                                  Valid       : out Boolean)
   is
      Buffer : String (1 .. 4096);
      Last   : Natural;
   begin
      Fds := (others => -1);
      Lookup.Find_Resource_Location (State, Serv_State, Buffer, Last, Valid);
      if Valid then
         Gneiss_Syscall.Open (Buffer (Buffer'First .. Last) & ASCII.NUL, Fds (Fds'First), 0);
      end if;
      Valid := Fds (Fds'First) > -1;
   end Process_Rom_Request;

   procedure Process_Timer_Request (Fds   : out Gneiss_Syscall.Fd_Array;
                                    Valid : out Boolean)
   is
   begin
      Fds := (others => -1);
      Gneiss_Syscall.Timerfd_Create (Fds (Fds'First));
      Valid := Fds (Fds'First) > -1;
   end Process_Timer_Request;

   procedure Process_Confirm (State : Broker_State;
                              Kind  : RFLX.Session.Kind_Type;
                              Name  : String;
                              Label : String;
                              Fds   : Gneiss_Syscall.Fd_Array)
   is
      Destination : Positive;
      Valid       : Boolean;
   begin
      Lookup.Find_Component_By_Name (State, Name, Destination, Valid);
      if Valid then
         case Kind is
            when RFLX.Session.Message | RFLX.Session.Log | RFLX.Session.Memory =>
               if Fds'Length > 0 and then Fds (Fds'First) >= 0 then
                  Send_Confirm (State.Components (Destination).Fd, Kind, Label, Fds (Fds'First .. Fds'First));
               else
                  Gneiss_Log.Warning ("Invalid Fd, rejecting");
                  Send_Reject (State.Components (Destination).Fd, Kind, Label);
               end if;
            when RFLX.Session.Rom | RFLX.Session.Timer =>
               Gneiss_Log.Warning ("Unexpected confirm");
         end case;
      else
         Gneiss_Log.Warning ("Failed to process confirm");
      end if;
   end Process_Confirm;

   procedure Process_Reject (State : Broker_State;
                             Kind  : RFLX.Session.Kind_Type;
                             Name  : String;
                             Label : String)
   is
      Destination : Positive;
      Valid       : Boolean;
   begin
      Lookup.Find_Component_By_Name (State, Name, Destination, Valid);
      if Valid then
         Send_Reject (State.Components (Destination).Fd, Kind, Label);
      else
         Gneiss_Log.Warning ("Failed to process reject");
      end if;
   end Process_Reject;

   procedure Process_Register (State  : in out Broker_State;
                               Source :        Positive;
                               Kind   :        RFLX.Session.Kind_Type)
   is
      Fds   : Gneiss_Syscall.Fd_Array (1 .. 1);
      Valid : Boolean;
   begin
      pragma Assert (if State.Components (Source).Fd > -1
                     then SXML.Query.State_Result (State.Components (Source).Node) = SXML.Result_OK
                          and then SXML.Query.Is_Valid (State.Components (Source).Node, State.Xml)
                          and then SXML.Query.Is_Open (State.Components (Source).Node, State.Xml));
      Setup_Service (State.Components (Source).Serv, Kind, State.Epoll_Fd, Valid);
      pragma Assert (Is_Valid (State.Xml, State.Components));
      Fds := (1 => State.Components (Source).Serv (Kind).Disp);
      if Valid then
         Send_Confirm (State.Components (Source).Fd, Kind, "", Fds);
      else
         Send_Reject (State.Components (Source).Fd, Kind, "");
      end if;
   end Process_Register;

   procedure Send_Request (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Name        : String;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array)
   is
      S_Name  : Gneiss_Internal.Session_Label;
      S_Label : Gneiss_Internal.Session_Label;
   begin
      S_Name.Last := S_Name.Value'First + Name'Length - 1;
      S_Name.Value (S_Name.Value'First .. S_Name.Last) := Name;
      S_Label.Last := S_Label.Value'First + Label'Length - 1;
      S_Label.Value (S_Label.Value'First .. S_Label.Last) := Label;
      Packet.Send (Destination, RFLX.Session.Request, Kind, S_Name, S_Label, Fds);
   end Send_Request;

   procedure Send_Confirm (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array)
   is
      S_Name  : Gneiss_Internal.Session_Label;
      S_Label : Gneiss_Internal.Session_Label;
   begin
      S_Label.Last := S_Label.Value'First + Label'Length - 1;
      S_Label.Value (S_Label.Value'First .. S_Label.Last) := Label;
      Packet.Send (Destination, RFLX.Session.Confirm, Kind, S_Name, S_Label, Fds);
   end Send_Confirm;

   procedure Send_Reject (Destination : Integer;
                          Kind        : RFLX.Session.Kind_Type;
                          Label       : String)
   is
      S_Name  : Gneiss_Internal.Session_Label;
      S_Label : Gneiss_Internal.Session_Label;
   begin
      S_Label.Last := S_Label.Value'First + Label'Length - 1;
      S_Label.Value (S_Label.Value'First .. S_Label.Last) := Label;
      Packet.Send (Destination, RFLX.Session.Reject, Kind, S_Name, S_Label, (1 .. 0 => -1));
   end Send_Reject;

end Gneiss.Broker.Message;
