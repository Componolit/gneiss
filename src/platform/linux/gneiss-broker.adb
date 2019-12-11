
with Ada.Unchecked_Conversion;
with Basalt.Strings;
with Gneiss.Syscall;
with Gneiss.Main;
with Gneiss.Protocoll;
with Gneiss_Epoll;
with Gneiss_Log;
with SXML.Parser;
with RFLX.Types;
with RFLX.Session;
with RFLX.Session.Packet;

package body Gneiss.Broker with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   package Proto is new Gneiss.Protocoll (RFLX.Types.Byte, RFLX_String);

   Policy  : Component_List (1 .. 1024);
   Efd     : Gneiss_Epoll.Epoll_Fd := -1;

   function Convert_Message (S : String) return RFLX_String;

   procedure Find_Component_By_Name (Name  :     String;
                                     Index : out Positive;
                                     Valid : out Boolean) with
      Post => (if Valid then Index in Policy'Range);

   procedure Start_Components (Root   :     SXML.Query.State_Type;
                               Status : out Integer;
                               Parent : out Boolean);

   procedure Load (Fd   :        Integer;
                   Comp :        SXML.Query.State_Type;
                   Ret  :    out Integer);

   procedure Event_Loop (Status : out Integer);

   procedure Read_Message (Index : Positive) with
      Pre => Index in Policy'Range;

   procedure Load_Message (Index   :        Positive;
                           Context : in out RFLX.Session.Packet.Context;
                           Fd      :        Integer) with
      Pre => Index in Policy'Range;

   procedure Handle_Message (Source : Positive;
                             Action : RFLX.Session.Action_Type;
                             Kind   : RFLX.Session.Kind_Type;
                             Name   : String;
                             Label  : String;
                             Fd     : Integer) with
      Pre => Source in Policy'Range;

   procedure Process_Request (Source : Positive;
                              Kind   : RFLX.Session.Kind_Type;
                              Label  : String) with
      Pre => Source in Policy'Range;

   procedure Process_Confirm (Kind   : RFLX.Session.Kind_Type;
                              Name   : String;
                              Label  : String;
                              Fd     : Integer);

   procedure Process_Reject (Kind  : RFLX.Session.Kind_Type;
                             Name  : String;
                             Label : String);

   procedure Send_Request (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Name        : String;
                           Label       : String);

   procedure Send_Confirm (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Label       : String;
                           Filedesc    : Integer);

   procedure Send_Reject (Destination : Integer;
                          Kind        : RFLX.Session.Kind_Type;
                          Label       : String);

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

   procedure Find_Component_By_Name (Name  :     String;
                                     Index : out Positive;
                                     Valid : out Boolean)
   is
      use type SXML.Result_Type;
      XML_Buf : String (1 .. 255);
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Index := Positive'Last;
      Valid := False;
      for I in Policy'Range loop
         if SXML.Query.State_Result (Policy (I).Node) = SXML.Result_OK then
            SXML.Query.Attribute (Policy (I).Node, Document, "name", Result, XML_Buf, Last);
            if
               Result = SXML.Result_OK
               and then Last in XML_Buf'Range
               and then Last - XML_Buf'First = Name'Last - Name'First
               and then XML_Buf (1 .. Last) = Name
            then
               Index := I;
               Valid := True;
               return;
            end if;
         end if;
      end loop;
   end Find_Component_By_Name;

   procedure Construct (Config :     String;
                        Status : out Integer)
   is
      use type SXML.Parser.Match_Type;
      use type SXML.Result_Type;
      Result   : SXML.Parser.Match_Type := SXML.Parser.Match_Invalid;
      Position : Natural;
      State    : SXML.Query.State_Type;
      Parent   : Boolean;
   begin
      if not SXML.Valid_Content (Config'First, Config'Last) then
         Gneiss_Log.Error ("Invalid content");
         Status := 1;
         return;
      end if;
      SXML.Parser.Parse (Config, Document, Position, Result);
      if
         Result /= SXML.Parser.Match_OK
      then
         case Result is
            when SXML.Parser.Match_OK =>
               Gneiss_Log.Error ("XML document parsed successfully");
            when SXML.Parser.Match_None =>
               Gneiss_Log.Error ("No XML data found");
            when SXML.Parser.Match_Invalid =>
               Gneiss_Log.Error ("Malformed XML data found");
            when SXML.Parser.Match_Out_Of_Memory =>
               Gneiss_Log.Error ("Out of context buffer memory");
            when SXML.Parser.Match_None_Wellformed =>
               Gneiss_Log.Error ("Document is not wellformed");
            when SXML.Parser.Match_Trailing_Data =>
               Gneiss_Log.Error ("Document successful parsed, but there is trailing data after it");
            when SXML.Parser.Match_Depth_Limit =>
               Gneiss_Log.Error ("Recursion depth exceeded");
         end case;
         Status := 1;
         return;
      end if;
      Gneiss_Epoll.Create (Efd);
      if Efd < 0 then
         Status := 1;
         return;
      end if;
      State := SXML.Query.Init (Document);
      if
         SXML.Query.State_Result (State) /= SXML.Result_OK
         or else not SXML.Query.Is_Open (State, Document)
      then
         Gneiss_Log.Error ("Init failed");
         return;
      end if;
      Start_Components (State, Status, Parent);
      if Parent then
         Event_Loop (Status);
      end if;
   end Construct;

   procedure Start_Components (Root   : SXML.Query.State_Type;
                               Status : out Integer;
                               Parent : out Boolean)
   is
      use type SXML.Result_Type;
      XML_Buf : String (1 .. 255);
      Pid     : Integer;
      Fd      : Integer;
      Success : Integer;
      Index   : Positive := Policy'First;
      State   : SXML.Query.State_Type;
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      State := SXML.Query.Path (Root, Document, "/config/component");
      Status := 0;
      while SXML.Query.State_Result (State) = SXML.Result_OK loop
         State := SXML.Query.Find_Sibling (State, Document, "component");
         exit when SXML.Query.State_Result (State) /= SXML.Result_OK;
         SXML.Query.Attribute (State, Document, "name", Result, XML_Buf, Last);
         if Result = SXML.Result_OK then
            Policy (Index).Node := State;
            Gneiss.Syscall.Socketpair (Policy (Index).Fd, Fd);
            Gneiss_Epoll.Add (Efd, Policy (Index).Fd, Index, Success);
            Gneiss.Syscall.Fork (Pid);
            if Pid < 0 then
               Status := 1;
               Gneiss_Log.Error ("Fork failed");
               Parent := True;
               return;
            elsif Pid > 0 then --  parent
               Policy (Index).Pid := Pid;
               Gneiss.Syscall.Close (Fd);
               Parent := True;
               Gneiss_Log.Info ("Started " & XML_Buf (XML_Buf'First .. Last)
                                & " with PID " & Basalt.Strings.Image (Pid));
            else --  Pid = 0, Child
               Load (Fd, State, Status);
               Parent := False;
               return;
            end if;
         else
            Gneiss_Log.Error ("Failed to load component name");
         end if;
         exit when Index = Policy'Last;
         Index := Index + 1;
         State := SXML.Query.Sibling (State, Document);
      end loop;
   end Start_Components;

   File_Name : String (1 .. 4096);

   procedure Load (Fd   :        Integer;
                   Comp :        SXML.Query.State_Type;
                   Ret  :    out Integer)
   is
      use type SXML.Result_Type;
      Result : SXML.Result_Type;
      Last   : Natural;
   begin
      Gneiss.Syscall.Close (Integer (Efd));
      for I in Policy'Range loop
         Policy (I).Node := SXML.Query.Invalid_State;
         Gneiss.Syscall.Close (Policy (I).Fd);
      end loop;
      SXML.Query.Attribute (Comp, Document, "file", Result, File_Name, Last);
      if Result /= SXML.Result_OK and then Last not in File_Name'Range then
         Gneiss_Log.Error ("No file to load");
         Ret := 1;
         return;
      end if;
      Gneiss.Main.Run (File_Name (File_Name'First .. Last), Fd, Ret);
   end Load;

   procedure Event_Loop (Status : out Integer)
   is
      XML_Buf : String (1 .. 255);
      Ev      : Gneiss_Epoll.Event;
      Index   : Integer;
      Success : Integer;
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Status := 1;
      loop
         Gneiss_Epoll.Wait (Efd, Ev, Index);
         if Index in Policy'Range then
            SXML.Query.Attribute (Policy (Index).Node, Document, "name", Result, XML_Buf, Last);
            if Ev.Epoll_In then
               Read_Message (Index);
            end if;
            if Ev.Epoll_Hup or else Ev.Epoll_Rdhup then
               Gneiss.Syscall.Waitpid (Policy (Index).Pid, Success);
               Gneiss_Log.Info ("Component "
                                & XML_Buf (XML_Buf'First .. Last)
                                & " exited with status "
                                & Basalt.Strings.Image (Success));
               Gneiss_Epoll.Remove (Efd, Policy (Index).Fd, Success);
               Gneiss.Syscall.Close (Policy (Index).Fd);
               Policy (Index).Node := SXML.Query.Invalid_State;
            end if;
         else
            Gneiss_Log.Warning ("Invalid index");
         end if;
      end loop;
   end Event_Loop;

   type Bytes_Ptr is access all RFLX.Types.Bytes;
   function Convert is new Ada.Unchecked_Conversion (Bytes_Ptr, RFLX.Types.Bytes_Ptr);
   --  FIXME: We have to convert access to access all to use it with 'Access, we should not do this
   Read_Buffer : aliased RFLX.Types.Bytes := (1 .. 512 => 0);

   procedure Read_Message (Index : Positive)
   is
      Truncated  : Boolean;
      Context    : RFLX.Session.Packet.Context;
      Buffer_Ptr : RFLX.Types.Bytes_Ptr := Convert (Read_Buffer'Access);
      Last       : RFLX.Types.Index;
      Fd         : Integer;
   begin
      Gneiss.Main.Peek_Message (Policy (Index).Fd, Read_Buffer, Last, Truncated, Fd);
      Gneiss.Syscall.Drop_Message (Policy (Index).Fd);
      if Truncated then
         Gneiss.Syscall.Close (Fd);
         Gneiss_Log.Warning ("Message too large, dropping");
         return;
      end if;
      RFLX.Session.Packet.Initialize (Context,
                                      Buffer_Ptr,
                                      RFLX.Types.First_Bit_Index (Read_Buffer'First),
                                      RFLX.Types.Last_Bit_Index (Last));
      RFLX.Session.Packet.Verify_Message (Context);
      if
         not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Action)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Kind)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Payload_Length)
         or else not RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload)
      then
         Gneiss_Log.Warning ("Invalid message, dropping");
         Gneiss.Syscall.Close (Fd);
         return;
      end if;
      Load_Message (Index, Context, Fd);
   end Read_Message;

   procedure Load_Message (Index   :        Positive;
                           Context : in out RFLX.Session.Packet.Context;
                           Fd      :        Integer)
   is
      use type RFLX.Types.Length;
      use type RFLX.Session.Length_Type;
      procedure Process_Payload (Payload : RFLX.Types.Bytes);
      procedure Get_Payload is new RFLX.Session.Packet.Get_Payload (Process_Payload);
      Name : String (1 .. Integer (RFLX.Session.Packet.Get_Name_Length (Context)));
      Label : String (1 .. Integer (RFLX.Session.Packet.Get_Payload_Length (Context)
                                    - RFLX.Session.Packet.Get_Name_Length (Context)));
      procedure Process_Payload (Payload : RFLX.Types.Bytes)
      is
         Label_First : constant RFLX.Types.Length :=
            Payload'First + RFLX.Types.Length (RFLX.Session.Packet.Get_Name_Length (Context));
      begin
         for I in Name'Range loop
            Name (I) := Character'Val (Payload (Payload'First + RFLX.Types.Length (I - Name'First)));
         end loop;
         for I in Label'Range loop
            Label (I) := Character'Val (Payload (Label_First + RFLX.Types.Length (I - Label'First)));
         end loop;
      end Process_Payload;
   begin
      if
         RFLX.Session.Packet.Has_Buffer (Context)
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload)
      then
         Get_Payload (Context);
         Handle_Message (Index,
                         RFLX.Session.Packet.Get_Action (Context),
                         RFLX.Session.Packet.Get_Kind (Context),
                         Name, Label, Fd);
      else
         Gneiss_Log.Warning ("Missing payload");
      end if;
   end Load_Message;

   procedure Handle_Message (Source : Positive;
                             Action : RFLX.Session.Action_Type;
                             Kind   : RFLX.Session.Kind_Type;
                             Name   : String;
                             Label  : String;
                             Fd     : Integer)
   is
   begin
      case Action is
         when RFLX.Session.Request =>
            Process_Request (Source, Kind, Label);
         when RFLX.Session.Confirm =>
            Process_Confirm (Kind, Name, Label, Fd);
         when RFLX.Session.Reject =>
            Process_Reject (Kind, Name, Label);
      end case;
   end Handle_Message;

   procedure Process_Request (Source : Positive;
                              Kind   : RFLX.Session.Kind_Type;
                              Label  : String)
   is
      use type SXML.Result_Type;
      XML_Buf     : String (1 .. 255);
      State       : SXML.Query.State_Type := SXML.Query.Child (Policy (Source).Node, Document);
      Destination : Positive;
      Valid       : Boolean;
      Result      : SXML.Result_Type := SXML.Result_Invalid;
      Last        : Natural;
   begin
      while SXML.Query.State_Result (State) = SXML.Result_OK loop
         State := SXML.Query.Find_Sibling (State, Document, "service", "name", Proto.Image (Kind));
         exit when SXML.Query.State_Result (State) /= SXML.Result_OK;
         SXML.Query.Attribute (State, Document, "label", Result, XML_Buf, Last);
         exit when (Result = SXML.Result_OK
                    and then Last in XML_Buf'Range
                    and then Last - XML_Buf'First = Label'Last - Label'First
                    and then XML_Buf (XML_Buf'First .. Last) = Label)
                   or else Result = SXML.Result_Not_Found;
         State := SXML.Query.Sibling (State, Document);
      end loop;
      if SXML.Query.State_Result (State) /= SXML.Result_OK then
         Gneiss_Log.Error ("No service found");
         Send_Reject (Policy (Source).Fd, Kind, Label);
         return;
      end if;
      SXML.Query.Attribute (State, Document, "server", Result, XML_Buf, Last);
      if Result /= SXML.Result_OK or else Last not in XML_Buf'Range then
         Gneiss_Log.Error ("Failed to get service provider");
         Send_Reject (Policy (Source).Fd, Kind, Label);
         return;
      end if;
      Find_Component_By_Name (XML_Buf (XML_Buf'First .. Last), Destination, Valid);
      if not Valid then
         Gneiss_Log.Error ("Service provider not found");
         Send_Reject (Policy (Source).Fd, Kind, Label);
         return;
      end if;
      SXML.Query.Attribute (Policy (Source).Node, Document, "name", Result, XML_Buf, Last);
      if Result /= SXML.Result_OK or else Last not in XML_Buf'Range then
         Gneiss_Log.Error ("Failed to get source name");
         Send_Reject (Policy (Source).Fd, Kind, Label);
         return;
      end if;
      Send_Request (Policy (Destination).Fd, Kind, XML_Buf (XML_Buf'First .. Last), Label);
   end Process_Request;

   procedure Process_Confirm (Kind   : RFLX.Session.Kind_Type;
                              Name   : String;
                              Label  : String;
                              Fd     : Integer)
   is
      Destination : Positive;
      Valid       : Boolean;
   begin
      Find_Component_By_Name (Name, Destination, Valid);
      if Valid then
         if Fd >= 0 then
            Send_Confirm (Policy (Destination).Fd, Kind, Label, Fd);
         else
            Gneiss_Log.Warning ("Invalid Fd, rejecting");
            Send_Reject (Policy (Destination).Fd, Kind, Label);
         end if;
      else
         Gneiss_Log.Warning ("Failed to process confirm");
      end if;
   end Process_Confirm;

   procedure Process_Reject (Kind   : RFLX.Session.Kind_Type;
                             Name   : String;
                             Label  : String)
   is
      Destination : Positive;
      Valid       : Boolean;
   begin
      Find_Component_By_Name (Name, Destination, Valid);
      if Valid then
         Send_Reject (Policy (Destination).Fd, Kind, Label);
      else
         Gneiss_Log.Warning ("Failed to process reject");
      end if;
   end Process_Reject;

   procedure Send_Request (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Name        : String;
                           Label       : String)
   is
   begin
      Proto.Send_Message (Destination,
                          Proto.Message'(Length      => RFLX.Session.Length_Type (Name'Length + Label'Length),
                                         Action      => RFLX.Session.Request,
                                         Kind        => Kind,
                                         Name_Length => RFLX.Session.Length_Type (Name'Length),
                                         Payload     => Convert_Message (Name & Label)));
   end Send_Request;

   procedure Send_Confirm (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Label       : String;
                           Filedesc    : Integer)
   is
   begin
      Proto.Send_Message (Destination,
                          Proto.Message'(Length      => RFLX.Session.Length_Type (Label'Length),
                                         Action      => RFLX.Session.Confirm,
                                         Kind        => Kind,
                                         Name_Length => 0,
                                         Payload     => Convert_Message (Label)),
                          Filedesc);
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

end Gneiss.Broker;
