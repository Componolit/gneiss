
with Gneiss.Main;
with Gneiss.Broker.Lookup;
with Gneiss.Protocol;
with Gneiss_Log;

package body Gneiss.Broker.Message with
   SPARK_Mode
is

   package Proto is new Gneiss.Protocol (RFLX.Types.Byte, RFLX_String);

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

   procedure Read_Message (State  :        Broker_State;
                           Index  :        Positive;
                           Buffer : in out RFLX.Types.Bytes_Ptr)
   is
      use type RFLX.Types.Length;
      Truncated : Boolean;
      Context   : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      Last      : RFLX.Types.Index;
      Fds       : Gneiss_Syscall.Fd_Array (1 .. 4);
   begin
      Gneiss.Main.Peek_Message (State.Components (Index).Fd, Buffer.all, Last, Truncated, Fds);
      Gneiss_Syscall.Drop_Message (State.Components (Index).Fd);
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
      if
         RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Action)
         and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Kind)
         and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length)
         and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Payload_Length)
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload)
      then
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

   procedure Load_Message (State   : Broker_State;
                           Index   : Positive;
                           Context : RFLX.Session.Packet.Context;
                           Fds     : Gneiss_Syscall.Fd_Array)
   is
      use type RFLX.Types.Length;
      use type RFLX.Session.Length_Type;
      Load_Message_Name  : String (1 .. 255);
      Load_Message_Label : String (1 .. 255);
      Length : constant RFLX.Types.Length := RFLX.Types.Length (RFLX.Session.Packet.Get_Name_Length (Context));
      procedure Process_Payload (Payload : RFLX.Types.Bytes) with
         Pre => Length < 256
         and then Payload'First < RFLX.Types.Length'Last - 512
         and then Payload'First <= Payload'Last;
      procedure Get_Payload is new RFLX.Session.Packet.Get_Payload (Process_Payload);
      Name_Last  : constant Natural := Natural (RFLX.Session.Packet.Get_Name_Length (Context));
      Label_Last : constant Natural := Natural (RFLX.Session.Packet.Get_Payload_Length (Context) -
                                          RFLX.Session.Packet.Get_Name_Length (Context));
      procedure Process_Payload (Payload : RFLX.Types.Bytes)
      is
         Label_First : constant RFLX.Types.Length := Payload'First + Length;
         Idx         : RFLX.Types.Length;
      begin
         --  FIXME: the for loops could be optimized by calculating the correct indices and
         --         replacing the loop with an if by two loops without one
         for I in Load_Message_Name'First .. Name_Last loop
            Idx := Payload'First + RFLX.Types.Length (I - Load_Message_Name'First);
            if Idx in Payload'Range then
               Load_Message_Name (I) := Character'Val (Payload (Idx));
            else
               Load_Message_Name (I) := Character'First;
            end if;
         end loop;
         for I in Load_Message_Label'First .. Label_Last loop
            Idx := Label_First + RFLX.Types.Length (I - Load_Message_Label'First);
            if Idx in Payload'Range then
               Load_Message_Label (I) := Character'Val (Payload (Idx));
            else
               Load_Message_Label (I) := Character'First;
            end if;
         end loop;
      end Process_Payload;
   begin
      if
         RFLX.Session.Packet.Has_Buffer (Context)
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload)
      then
         Get_Payload (Context);
         Handle_Message (State, Index,
                         RFLX.Session.Packet.Get_Action (Context),
                         RFLX.Session.Packet.Get_Kind (Context),
                         Load_Message_Name (Load_Message_Name'First .. Name_Last),
                         Load_Message_Label (Load_Message_Label'First .. Label_Last),
                         Fds);
      else
         Gneiss_Log.Warning ("Missing payload");
      end if;
   end Load_Message;

   procedure Handle_Message (State  : Broker_State;
                             Source : Positive;
                             Action : RFLX.Session.Action_Type;
                             Kind   : RFLX.Session.Kind_Type;
                             Name   : String;
                             Label  : String;
                             Fds    : Gneiss_Syscall.Fd_Array)
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
      end case;
   end Handle_Message;

   procedure Process_Request (State  : Broker_State;
                              Source : Positive;
                              Kind   : RFLX.Session.Kind_Type;
                              Label  : String;
                              Fds    : Gneiss_Syscall.Fd_Array)
   is
      use type SXML.Query.State_Type;
      use type SXML.Result_Type;
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
      Lookup.Match_Service (State.Xml, State.Components (Source).Node, Proto.Image (Kind), Label, Serv_State);
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
               Send_Request (State.Components (Destination).Fd,
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

   procedure Send_Request (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Name        : String;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array)
   is
   begin
      Proto.Send_Message (Destination,
                          Proto.Message'(Length      => RFLX.Session.Length_Type (Name'Length + Label'Length),
                                         Action      => RFLX.Session.Request,
                                         Kind        => Kind,
                                         Name_Length => RFLX.Session.Length_Type (Name'Length),
                                         Payload     => Convert_Message (Name & Label)),
                          Fds);
   end Send_Request;

   procedure Send_Confirm (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array)
   is
   begin
      Proto.Send_Message (Destination,
                          Proto.Message'(Length      => RFLX.Session.Length_Type (Label'Length),
                                         Action      => RFLX.Session.Confirm,
                                         Kind        => Kind,
                                         Name_Length => 0,
                                         Payload     => Convert_Message (Label)),
                          Fds);
   end Send_Confirm;

   procedure Send_Reject (Destination : Integer;
                          Kind        : RFLX.Session.Kind_Type;
                          Label       : String)
   is
   begin
      Proto.Send_Message (Destination, Proto.Message'(Length      => RFLX.Session.Length_Type (Label'Length),
                                                      Action      => RFLX.Session.Reject,
                                                      Kind        => Kind,
                                                      Name_Length => 0,
                                                      Payload     => Convert_Message (Label)));
   end Send_Reject;

end Gneiss.Broker.Message;
