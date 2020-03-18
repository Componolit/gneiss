
with System;
with Gneiss.Broker.Lookup;
with Gneiss_Log;
with Gneiss_Access;

package body Gneiss.Broker.Message with
   SPARK_Mode
is
   use type System.Address;
   use type RFLX.Types.Bytes_Ptr;
   use type RFLX.Types.Length;

   package Send_Buf is new Gneiss_Access (520);

   function Buf_Address return System.Address with
      Pre  => Send_Buf.Ptr /= null,
      Post => Buf_Address'Result /= System.Null_Address;

   function Image (V : RFLX.Session.Kind_Type) return String is
      (case V is
         when RFLX.Session.Message => "Message",
         when RFLX.Session.Log     => "Log",
         when RFLX.Session.Memory  => "Memory",
         when RFLX.Session.Rom     => "Rom");

   function Buf_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Send_Buf.Ptr.all'Address;
   end Buf_Address;

   procedure Peek_Message (Socket    :     Integer;
                           Msg       : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean;
                           Fd        : out Gneiss_Syscall.Fd_Array);

   procedure Setup_Service (State : in out Broker_State;
                            Kind  :        RFLX.Session.Kind_Type;
                            Index :        Positive);

   procedure Send_Message (Destination : Integer;
                           Action      : RFLX.Session.Action_Type;
                           Kind        : RFLX.Session.Kind_Type;
                           Name        : String;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array) with
      Pre => Send_Buf.Ptr /= null,
      Post => Send_Buf.Ptr /= null;

   procedure Peek_Message (Socket    :     Integer;
                           Msg       : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean;
                           Fd        : out Gneiss_Syscall.Fd_Array) with
      SPARK_Mode => Off
   is
      Trunc     : Integer;
      Length    : Integer;
   begin
      Gneiss_Syscall.Peek_Message (Socket, Msg'Address, Msg'Length, Fd, Fd'Length, Length, Trunc);
      Truncated := Trunc = 1;
      if Length < 1 then
         Last := RFLX.Types.Index'First;
         return;
      end if;
      Last := (Msg'First + RFLX.Types.Index (Length)) - 1;
   end Peek_Message;

   procedure Setup_Service (State : in out Broker_State;
                            Kind  :        RFLX.Session.Kind_Type;
                            Index :        Positive)
   is
      Ignore_Success : Integer;
   begin
      if
         State.Components (Index).Serv (Kind).Broker > -1
         and then State.Components (Index).Serv (Kind).Disp > -1
      then
         return;
      end if;
      Gneiss_Syscall.Socketpair (State.Components (Index).Serv (Kind).Broker,
                                 State.Components (Index).Serv (Kind).Disp);
      if
         State.Components (Index).Serv (Kind).Broker < 0
         or else State.Components (Index).Serv (Kind).Disp < 0
      then
         Gneiss_Log.Error ("Failed to create service fds");
         Gneiss_Syscall.Close (State.Components (Index).Serv (Kind).Broker);
         Gneiss_Syscall.Close (State.Components (Index).Serv (Kind).Disp);
         return;
      end if;
      Gneiss_Epoll.Add (State.Epoll_Fd, State.Components (Index).Serv (Kind).Broker,
                        State.Components (Index).Serv (Kind).Broker, Ignore_Success);
   end Setup_Service;

   procedure Send_Message (Destination : Integer;
                           Action      : RFLX.Session.Action_Type;
                           Kind        : RFLX.Session.Kind_Type;
                           Name        : String;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array)
   is
      Context : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      procedure Convert_Name is new Send_Buf.Set (Name);
      procedure Convert_Label is new Send_Buf.Set (Label);
      procedure Set_Name is new RFLX.Session.Packet.Set_Name (Convert_Name);
      procedure Set_Label is new RFLX.Session.Packet.Set_Label (Convert_Label);
   begin
      RFLX.Session.Packet.Initialize (Context, Send_Buf.Ptr);
      RFLX.Session.Packet.Set_Action (Context, Action);
      RFLX.Session.Packet.Set_Kind (Context, Kind);
      RFLX.Session.Packet.Set_Name_Length (Context, Name'Length);
      if Name'Length > 0 then
         Set_Name (Context);
      end if;
      RFLX.Session.Packet.Set_Label_Length (Context, Label'Length);
      if Label'Length > 0 then
         Set_Label (Context);
      end if;
      RFLX.Session.Packet.Take_Buffer (Context, Send_Buf.Ptr);
      Gneiss_Syscall.Write_Message (Destination,
                                    Buf_Address,
                                    4 + Name'Length + Label'Length,
                                    Fds, Fds'Length);
   end Send_Message;

   function Convert_Message (S : String) return RFLX_String
   is
      use type RFLX.Session.Length_Type;
      R : RFLX_String (1 .. RFLX.Session.Length_Type (S'Length));
   begin
      for I in R'Range loop
         R (I) := S (S'First + Natural (I - R'First));
      end loop;
      return R;
   end Convert_Message;

   procedure Read_Message (State    : in out Broker_State;
                           Index    :        Positive;
                           Filedesc :        Integer;
                           Buffer   : in out RFLX.Types.Bytes_Ptr)
   is
      Truncated : Boolean;
      Context   : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      Last      : RFLX.Types.Index;
      Fds       : Gneiss_Syscall.Fd_Array (1 .. 4);
   begin
      Peek_Message (Filedesc, Buffer.all, Last, Truncated, Fds);
      Gneiss_Syscall.Drop_Message (Filedesc);
      if Last < Buffer.all'First then
         pragma Warnings (Off, "unused assignment to ""Fd""");
         for Fd of Fds loop
            Gneiss_Syscall.Close (Fd);
         end loop;
         pragma Warnings (On, "unused assignment to ""Fd""");
         Gneiss_Log.Warning ("Message too short, dropping");
         return;
      end if;
      if Truncated or else Last > Buffer.all'Last then
         pragma Warnings (Off, "unused assignment to ""Fd""");
         for Fd of Fds loop
            Gneiss_Syscall.Close (Fd);
         end loop;
         pragma Warnings (On, "unused assignment to ""Fd""");
         Gneiss_Log.Warning ("Message too large, dropping");
         return;
      end if;
      pragma Warnings (Off, "unused assignment to ""Ptr""");
      RFLX.Session.Packet.Initialize (Context,
                                      Buffer,
                                      RFLX.Types.First_Bit_Index (Buffer.all'First),
                                      RFLX.Types.Last_Bit_Index (Last));
      pragma Warnings (On, "unused assignment to ""Ptr""");
      RFLX.Session.Packet.Verify_Message (Context);
      if RFLX.Session.Packet.Structural_Valid_Message (Context) then
         Load_Message (State, Index, Context, Fds);
      else
         Gneiss_Log.Warning ("Invalid message, dropping");
         pragma Warnings (Off, "unused assignment to ""Fd""");
         for Fd of Fds loop
            Gneiss_Syscall.Close (Fd);
         end loop;
         pragma Warnings (On, "unused assignment to ""Fd""");
      end if;
      pragma Warnings (Off, "unused assignment to ""Context""");
      RFLX.Session.Packet.Take_Buffer (Context, Buffer);
      pragma Warnings (On, "unused assignment to ""Context""");
   end Read_Message;

   procedure Load_Message (State   : in out Broker_State;
                           Index   :        Positive;
                           Context :        RFLX.Session.Packet.Context;
                           Fds     :        Gneiss_Syscall.Fd_Array)
   is
      Load_Message_Name  : String (1 .. 255) := (others => Character'First);
      Load_Message_Label : String (1 .. 255) := (others => Character'First);
      Name_Last          : Natural           := 0;
      Label_Last         : Natural           := 0;
      procedure Load_Name is new Send_Buf.Get (Load_Message_Name, Name_Last);
      procedure Load_Label is new Send_Buf.Get (Load_Message_Label, Label_Last);
      procedure Get_Name is new RFLX.Session.Packet.Get_Name (Load_Name);
      procedure Get_Label is new RFLX.Session.Packet.Get_Label (Load_Label);
   begin
      if RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Name) then
         Get_Name (Context);
      end if;
      if RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Label) then
         Get_Label (Context);
      end if;
      Handle_Message (State, Index,
                      RFLX.Session.Packet.Get_Action (Context),
                      RFLX.Session.Packet.Get_Kind (Context),
                      Load_Message_Name (Load_Message_Name'First .. Name_Last),
                      Load_Message_Label (Load_Message_Label'First .. Label_Last),
                      Fds);
   end Load_Message;

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
      pragma Unreferenced (Fds);
      Serv_State  : SXML.Query.State_Type;
      Destination : Integer;
      Valid       : Boolean;
      Source_Name : String (1 .. 255);
      Last        : Natural;
      Result      : SXML.Result_Type;
      Fds_Out     : Gneiss_Syscall.Fd_Array (1 .. 4) := (others => -1);
   begin
      if State.Components (Source).Fd < 0 then
         Gneiss_Log.Warning ("Cannot process invalid source");
         return;
      end if;
      Lookup.Match_Service (State.Xml, State.Components (Source).Node, Image (Kind), Label, Serv_State);
      if Serv_State = SXML.Query.Invalid_State then
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
            Process_Message_Request (Fds_Out, Valid);
            if Valid and then Destination in State.Components'Range then
               Setup_Service (State, Kind, Destination);
               Send_Request (State.Components (Destination).Serv (Kind).Broker,
                             Kind,
                             Source_Name (Source_Name'First .. Last),
                             Label,
                             Fds_Out (Fds_Out 'First .. Fds_Out'First + 1));
            else
               Send_Reject (State.Components (Source).Fd, Kind, Label);
            end if;
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
            Gneiss_Log.Warning ("Memory interface currently not supported");
            Send_Reject (State.Components (Source).Fd, Kind, Label);
      end case;
   end Process_Request;

   procedure Process_Message_Request (Fds : out Gneiss_Syscall.Fd_Array;
                                      Valid : out Boolean)
   is
   begin
      Fds := (others => -1);
      Gneiss_Syscall.Socketpair (Fds (Fds'First), Fds (Fds'First + 1));
      Valid := Fds (Fds'First) > -1 and then Fds (Fds'First + 1) > -1;
      if not Valid then
         Gneiss_Syscall.Close (Fds (Fds'First));
         Gneiss_Syscall.Close (Fds (Fds'First + 1));
      end if;
   end Process_Message_Request;

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
            when RFLX.Session.Message | RFLX.Session.Log =>
               if Fds (Fds'First) >= 0 then
                  Send_Confirm (State.Components (Destination).Fd, Kind, Label, Fds (Fds'First .. Fds'First));
               else
                  Gneiss_Log.Warning ("Invalid Fd, rejecting");
                  Send_Reject (State.Components (Destination).Fd, Kind, Label);
               end if;
            when RFLX.Session.Rom | RFLX.Session.Memory =>
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
      Fds : Gneiss_Syscall.Fd_Array (1 .. 1);
   begin
      Setup_Service (State, Kind, Source);
      Fds := (1 => State.Components (Source).Serv (Kind).Disp);
      if Fds (Fds'First) > -1 then
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
   begin
      Send_Message (Destination, RFLX.Session.Request, Kind, Name, Label, Fds);
   end Send_Request;

   procedure Send_Confirm (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array)
   is
   begin
      Send_Message (Destination, RFLX.Session.Confirm, Kind, "", Label, Fds);
   end Send_Confirm;

   procedure Send_Reject (Destination : Integer;
                          Kind        : RFLX.Session.Kind_Type;
                          Label       : String)
   is
      Null_Fds : constant Gneiss_Syscall.Fd_Array (1 .. 0) := (others => -1);
   begin
      Send_Message (Destination, RFLX.Session.Reject, Kind, "", Label, Null_Fds);
   end Send_Reject;

end Gneiss.Broker.Message;
