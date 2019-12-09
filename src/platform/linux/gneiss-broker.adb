
with Ada.Unchecked_Conversion;
with Gneiss.Syscall;
with Gneiss.Main;
with Gneiss.Protocoll;
with Gneiss_Epoll;
with Basalt.Strings;
with Basalt.Strings_Generic;
with SXML.Parser;
with RFLX.Types;
with RFLX.Session;
with RFLX.Session.Packet;
with Componolit.Runtime.Debug;

package body Gneiss.Broker with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   package Proto is new Gneiss.Protocoll (RFLX.Types.Byte, RFLX_String);

   Policy  : Component_List (1 .. 1024);
   Efd     : Gneiss_Epoll.Epoll_Fd := -1;
   XML_Buf : String (1 .. 255);

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
      Result : SXML.Result_Type;
      Last   : Natural;
   begin
      Index := Positive'Last;
      Valid := False;
      for I in Policy'Range loop
         if Policy (I).Node.Result = SXML.Result_OK then
            SXML.Query.Attribute (Policy (I).Node, Document, "name", Result, XML_Buf, Last);
            Componolit.Runtime.Debug.Log_Debug ("Lookup (" & Basalt.Strings.Image (Last) & "): " & XML_Buf);
            if
               Result = SXML.Result_OK
               and then Last in XML_Buf'Range
               and then Last - XML_Buf'First = Name'Last - Name'First
               and then XML_Buf (1 .. Last) = Name
            then
               Index := I;
               Valid := True;
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
         Componolit.Runtime.Debug.Log_Error ("Invalid content");
         Status := 1;
         return;
      end if;
      SXML.Parser.Parse (Config, Document, Result, Position);
      if
         Result /= SXML.Parser.Match_OK
      then
         case Result is
            when SXML.Parser.Match_OK =>
               Componolit.Runtime.Debug.Log_Error ("XML document parsed successfully");
            when SXML.Parser.Match_None =>
               Componolit.Runtime.Debug.Log_Error ("No XML data found");
            when SXML.Parser.Match_Invalid =>
               Componolit.Runtime.Debug.Log_Error ("Malformed XML data found");
            when SXML.Parser.Match_Out_Of_Memory =>
               Componolit.Runtime.Debug.Log_Error ("Out of context buffer memory");
            when SXML.Parser.Match_None_Wellformed =>
               Componolit.Runtime.Debug.Log_Error ("Document is not wellformed");
            when SXML.Parser.Match_Trailing_Data =>
               Componolit.Runtime.Debug.Log_Error ("Document successful parsed, but there is trailing data after it");
            when SXML.Parser.Match_Depth_Limit =>
               Componolit.Runtime.Debug.Log_Error ("Recursion depth exceeded");
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
         State.Result /= SXML.Result_OK
         or else not SXML.Query.Is_Open (Document, State)
      then
         Componolit.Runtime.Debug.Log_Error ("Init failed");
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
      while State.Result = SXML.Result_OK loop
         State := SXML.Query.Find_Sibling (State, Document, "component");
         exit when State.Result /= SXML.Result_OK;
         SXML.Query.Attribute (State, Document, "name", Result, XML_Buf, Last);
         if Result = SXML.Result_OK then
            Policy (Index).Node := State;
            Gneiss.Syscall.Socketpair (Policy (Index).Fd, Fd);
            Gneiss_Epoll.Add (Efd, Policy (Index).Fd, Index, Success);
            Gneiss.Syscall.Fork (Pid);
            if Pid < 0 then
               Status := 1;
               Componolit.Runtime.Debug.Log_Error ("Fork failed");
               Parent := True;
               return;
            elsif Pid > 0 then --  parent
               Policy (Index).Pid := Pid;
               Gneiss.Syscall.Close (Fd);
               Parent := True;
            else --  Pid = 0, Child
               Load (Fd, State, Status);
               Parent := False;
               return;
            end if;
         else
            Componolit.Runtime.Debug.Log_Warning ("Failed to load component name");
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
         Componolit.Runtime.Debug.Log_Error ("No file to load");
         Ret := 1;
         return;
      end if;
      Gneiss.Main.Run (File_Name (File_Name'First .. Last), Fd, Ret);
   end Load;

   procedure Event_Loop (Status : out Integer)
   is
      Ev      : Gneiss_Epoll.Event;
      Index   : Integer;
      Success : Integer;
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Status := 1;
      loop
         Gneiss_Epoll.Wait (Efd, Ev, Index);
         Componolit.Runtime.Debug.Log_Debug ("Broker Event");
         if Index in Policy'Range then
            SXML.Query.Attribute (Policy (Index).Node, Document, "name", Result, XML_Buf, Last);
            if Ev.Epoll_In then
               Componolit.Runtime.Debug.Log_Debug ("Received command from " & XML_Buf (XML_Buf'First .. Last));
               Read_Message (Index);
            end if;
            if Ev.Epoll_Hup or else Ev.Epoll_Rdhup then
               Gneiss.Syscall.Waitpid (Policy (Index).Pid, Success);
               Componolit.Runtime.Debug.Log_Debug ("Component "
                                                   & XML_Buf (XML_Buf'First .. Last)
                                                   & " exited with status "
                                                   & Basalt.Strings.Image (Success));
               Gneiss_Epoll.Remove (Efd, Policy (Index).Fd, Success);
               Gneiss.Syscall.Close (Policy (Index).Fd);
               Policy (Index).Node := SXML.Query.Invalid_State;
            end if;
         else
            Componolit.Runtime.Debug.Log_Warning ("Invalid index");
         end if;
      end loop;
   end Event_Loop;

   type Bytes_Ptr is access all RFLX.Types.Bytes;
   function Convert is new Ada.Unchecked_Conversion (Bytes_Ptr, RFLX.Types.Bytes_Ptr);
   --  FIXME: We have to convert access to access all to use it with 'Access, we should not do this
   Read_Buffer : aliased RFLX.Types.Bytes := (1 .. 512 => 0);

   procedure Read_Message (Index : Positive)
   is
      function Image is new Basalt.Strings_Generic.Image_Modular (RFLX.Session.Length_Type);
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
         Componolit.Runtime.Debug.Log_Warning ("Message too large, dropping");
         return;
      end if;
      Componolit.Runtime.Debug.Log_Debug ("Parsing...");
      RFLX.Session.Packet.Initialize (Context,
                                      Buffer_Ptr,
                                      RFLX.Types.First_Bit_Index (Read_Buffer'First),
                                      RFLX.Types.Last_Bit_Index (Last));
      RFLX.Session.Packet.Verify_Message (Context);
      Componolit.Runtime.Debug.Log_Debug
         ("Valid: "
          & " F_Action="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Action))
          & " F_Kind="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Kind))
          & " F_Name_Length="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length))
          & " F_Payload_Length="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Payload_Length))
          & " F_Payload="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Payload))
          );
      Componolit.Runtime.Debug.Log_Debug
         ("Present: "
          & " F_Action="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Action))
          & " F_Kind="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Kind))
          & " F_Name_Length="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Name_Length))
          & " F_Payload_Length="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload_Length))
          & " F_Payload="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload))
          );
      if
         not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Action)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Kind)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Payload_Length)
         or else not RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload)
      then
         Componolit.Runtime.Debug.Log_Warning ("Invalid message, dropping");
         Gneiss.Syscall.Close (Fd);
         return;
      end if;
      Componolit.Runtime.Debug.Log_Debug ("Name=" & Image (RFLX.Session.Packet.Get_Name_Length (Context))
                                          & " Payload=" & Image (RFLX.Session.Packet.Get_Payload_Length (Context)));
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
         Componolit.Runtime.Debug.Log_Warning ("Missing payload");
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
      Componolit.Runtime.Debug.Log_Debug ("Message:");
      Componolit.Runtime.Debug.Log_Debug (Name);
      Componolit.Runtime.Debug.Log_Debug (Label);
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
      State       : SXML.Query.State_Type := SXML.Query.Child (Policy (Source).Node, Document);
      Destination : Positive;
      Valid       : Boolean;
      Result      : SXML.Result_Type := SXML.Result_Invalid;
      Last        : Natural;
   begin
      Componolit.Runtime.Debug.Log_Debug ("Check type and label");
      while State.Result = SXML.Result_OK loop
         State := SXML.Query.Find_Sibling (State, Document, "service", "name", Proto.Image (Kind));
         exit when State.Result /= SXML.Result_OK;
         SXML.Query.Attribute (State, Document, "label", Result, XML_Buf, Last);
         Componolit.Runtime.Debug.Log_Debug (case Result is
                                                when SXML.Result_OK        => "Result_OK",
                                                when SXML.Result_Overflow  => "Result_Overflow",
                                                when SXML.Result_Invalid   => "Result_Invalid",
                                                when SXML.Result_Not_Found => "Result_Not_Found");
         exit when (Result = SXML.Result_OK
                    and then Last in XML_Buf'Range
                    and then Last - XML_Buf'First = Label'Last - Label'First
                    and then XML_Buf (XML_Buf'First .. Last) = Label)
                   or else Result = SXML.Result_Invalid; --  FIXME: this should be SXML.Result_Not_Found
         State := SXML.Query.Sibling (State, Document);
      end loop;
      if State.Result /= SXML.Result_OK then
         Componolit.Runtime.Debug.Log_Error ("No service found");
         Send_Reject (Policy (Source).Fd, Kind, Label);
         return;
      end if;
      Componolit.Runtime.Debug.Log_Debug ("Lookup service");
      SXML.Query.Attribute (State, Document, "server", Result, XML_Buf, Last);
      if Result /= SXML.Result_OK or else Last not in XML_Buf'Range then
         Componolit.Runtime.Debug.Log_Error ("Failed to get service provider");
         Send_Reject (Policy (Source).Fd, Kind, Label);
         return;
      end if;
      Componolit.Runtime.Debug.Log_Debug ("-> " & XML_Buf (XML_Buf'First .. Last) & " -> " & Label);
      Componolit.Runtime.Debug.Log_Debug ("Lookup server");
      Find_Component_By_Name (XML_Buf (XML_Buf'First .. Last), Destination, Valid);
      if not Valid then
         Componolit.Runtime.Debug.Log_Error ("Service provider not found");
         Send_Reject (Policy (Source).Fd, Kind, Label);
         return;
      end if;
      Componolit.Runtime.Debug.Log_Debug ("Lookup source name");
      SXML.Query.Attribute (Policy (Source).Node, Document, "name", Result, XML_Buf, Last);
      if Result /= SXML.Result_OK or else Last not in XML_Buf'Range then
         Componolit.Runtime.Debug.Log_Error ("Failed to get source name");
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
      Componolit.Runtime.Debug.Log_Debug ("Process_Confirm " & Name & " " & Label
                                          & " " & Basalt.Strings.Image (Fd));
      Find_Component_By_Name (Name, Destination, Valid);
      if Valid then
         if Fd >= 0 then
            Send_Confirm (Policy (Destination).Fd, Kind, Label, Fd);
         else
            Componolit.Runtime.Debug.Log_Warning ("Invalid Fd, rejecting");
            Send_Reject (Policy (Destination).Fd, Kind, Label);
         end if;
      else
         Componolit.Runtime.Debug.Log_Warning ("Failed to process confirm");
      end if;
   end Process_Confirm;

   procedure Process_Reject (Kind   : RFLX.Session.Kind_Type;
                             Name   : String;
                             Label  : String)
   is
      Destination : Positive;
      Valid       : Boolean;
   begin
      Componolit.Runtime.Debug.Log_Debug ("Process_Reject " & Name & " " & Label);
      Find_Component_By_Name (Name, Destination, Valid);
      if Valid then
         Send_Reject (Policy (Destination).Fd, Kind, Label);
      else
         Componolit.Runtime.Debug.Log_Warning ("Failed to process reject");
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
