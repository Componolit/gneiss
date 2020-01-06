
with Basalt.Strings;
with Gneiss.Protocol;
with Gneiss_Access;
with Gneiss_Log;
with SXML;
with SXML.Query;
with RFLX.Types;
with RFLX.Session;
with RFLX.Session.Packet;

package body Gneiss.Broker with
   SPARK_Mode,
   Refined_State => (Policy_State => (Document,
                                      Policy,
                                      Efd,
                                      Read_Buffer.Ptr,
                                      Proto.Linux,
                                      Load_File_Name,
                                      Load_Message_Name,
                                      Load_Message_Label))
is
   use type Gneiss_Epoll.Epoll_Fd;
   use type SXML.Result_Type;
   use type RFLX.Types.Bytes_Ptr;
   use type RFLX.Types.Length;

   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   package Proto is new Gneiss.Protocol (RFLX.Types.Byte, RFLX_String);

   Buffer_Size : constant RFLX.Types.Length := 512;
   package Read_Buffer is new Gneiss_Access (Buffer_Size);

   Document : SXML.Document_Type (1 .. 100) := (others => SXML.Null_Node);

   type Component is record
      Fd   : Integer               := -1;
      Node : SXML.Query.State_Type := SXML.Query.Initial_State;
      Pid  : Integer               := -1;
   end record;

   type Component_List is array (Positive range <>) of Component;

   Policy             : Component_List (1 .. 1024);
   Efd                : Gneiss_Epoll.Epoll_Fd := -1;
   Load_File_Name     : String (1 .. 4096)    := (others => Character'First);
   Load_Message_Name  : String (1 .. 255)     := (others => Character'First);
   Load_Message_Label : String (1 .. 255)     := (others => Character'First);

   function Is_Valid return Boolean is
      (for all P of Policy => SXML.Query.Is_Valid (P.Node, Document));

   function Initialized return Boolean is
      (Gneiss_Epoll.Valid_Fd (Efd)
       and then (for all P of Policy =>
         ((if P.Fd > -1
           then P.Pid > -1
                and then SXML.Query.State_Result (P.Node) = SXML.Result_OK
                and then SXML.Query.Is_Open (P.Node, Document)))));

   function Valid_Read_Buffer return Boolean is
      (Read_Buffer.Ptr /= null
       and then Read_Buffer.Ptr.all'First = 1
       and then Read_Buffer.Ptr.all'Last = Buffer_Size);

   function Convert_Message (S : String) return RFLX_String with
      Pre  => S'Length < 256,
      Post => Convert_Message'Result'Length = S'Length;

   procedure Find_Component_By_Name (Name  :     String;
                                     Index : out Positive;
                                     Valid : out Boolean) with
      Global => (Input    => (Document, Policy),
                 Proof_In => Efd),
      Pre    => Is_Valid
                and then Initialized
                and then Name'Length < 256,
      Post   => (if Valid then Index in Policy'Range);

   procedure Start_Components (Root   :     SXML.Query.State_Type;
                               Parent : out Boolean;
                               Status : out Integer) with
      Pre    => Is_Valid
                and then Initialized
                and then SXML.Query.Is_Valid (Root, Document)
                and then SXML.Query.State_Result (Root) = SXML.Result_OK
                and then SXML.Query.Is_Open (Root, Document),
      Post   => Is_Valid
                and then (if Parent then Initialized),
      Global => (Input  => Document,
                 In_Out => (Policy,
                            Efd,
                            Gneiss_Epoll.Linux,
                            Gneiss.Syscall.Linux,
                            Main.Component_State,
                            Load_File_Name,
                            Gneiss.Linker.Linux));

   procedure Load (Fd   :     Integer;
                   Comp :     SXML.Query.State_Type;
                   Ret  : out Integer) with
      Pre    => Is_Valid
                and then SXML.Query.Is_Valid (Comp, Document)
                and then SXML.Query.State_Result (Comp) = SXML.Result_OK
                and then SXML.Query.Is_Open (Comp, Document),
      Post   => Is_Valid,
      Global => (Input  => Document,
                 In_Out => (Policy,
                            Efd,
                            Gneiss.Syscall.Linux,
                            Main.Component_State,
                            Gneiss.Linker.Linux,
                            Gneiss_Epoll.Linux),
                 Output => Load_File_Name);

   procedure Event_Loop (Status : out Integer) with
      Pre    => Is_Valid
                and then Initialized
                and then Valid_Read_Buffer,
      Post   => Is_Valid
                and then Initialized
                and then Valid_Read_Buffer,
      Global => (Input  => (Document,
                            Efd),
                 In_Out => (Policy,
                            Load_Message_Name,
                            Load_Message_Label,
                            Gneiss_Epoll.Linux,
                            Gneiss.Syscall.Linux,
                            Proto.Linux,
                            Read_Buffer.Ptr));

   procedure Read_Message (Index : Positive) with
      Pre    => Index in Policy'Range
                and then Is_Valid
                and then Initialized
                and then Valid_Read_Buffer,
      Post   => Is_Valid
                and then Initialized
                and then Valid_Read_Buffer,
      Global => (Input    => (Document,
                              Policy),
                 In_Out   => (Gneiss.Syscall.Linux,
                              Proto.Linux,
                              Read_Buffer.Ptr,
                              Load_Message_Name,
                              Load_Message_Label),
                 Proof_In => Efd);

   procedure Load_Message (Index   : Positive;
                           Context : RFLX.Session.Packet.Context;
                           Fd      : Integer) with
      Pre    => Index in Policy'Range
                and then Is_Valid
                and then Initialized
                and then RFLX.Session.Packet.Valid_Context (Context)
                and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Action)
                and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Kind)
                and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length)
                and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Payload_Length)
                and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload),
      Post   => Is_Valid
                and then Initialized,
      Global => (Input    => (Document,
                              Policy),
                 In_Out   => (Load_Message_Name,
                              Load_Message_Label,
                              Gneiss.Syscall.Linux,
                              Proto.Linux),
                 Proof_In => Efd);

   procedure Handle_Message (Source : Positive;
                             Action : RFLX.Session.Action_Type;
                             Kind   : RFLX.Session.Kind_Type;
                             Name   : String;
                             Label  : String;
                             Fd     : Integer) with
      Pre    => Is_Valid
                and then Initialized
                and then Source in Policy'Range,
      Post   => Is_Valid
                and then Initialized,
      Global => (Input    => (Document,
                              Policy),
                 In_Out   => (Gneiss.Syscall.Linux,
                              Proto.Linux),
                 Proof_In => Efd);

   procedure Process_Request (Source : Positive;
                              Kind   : RFLX.Session.Kind_Type;
                              Label  : String) with
      Pre    => Is_Valid
                and then Initialized
                and then Label'Length < 256
                and then Source in Policy'Range,
      Post   => Is_Valid
                and then Initialized,
      Global => (Input    => (Document,
                              Policy),
                 In_Out   => (Gneiss.Syscall.Linux,
                              Proto.Linux),
                 Proof_In => Efd);

   procedure Process_Confirm (Kind  : RFLX.Session.Kind_Type;
                              Name  : String;
                              Label : String;
                              Fd    : Integer) with
      Pre    => Is_Valid
                and then Initialized
                and then Name'Length < 256
                and then Name'Length + Label'Length < 256,
      Post   => Is_Valid
                and then Initialized,
      Global => (Input    => (Document,
                              Policy),
                 In_Out   => (Gneiss.Syscall.Linux,
                              Proto.Linux),
                 Proof_In => Efd);

   procedure Process_Reject (Kind  : RFLX.Session.Kind_Type;
                             Name  : String;
                             Label : String) with
      Pre    => Is_Valid
                and then Initialized
                and then Name'Length < 256
                and then Name'Length + Label'Length < 256,
      Post   => Is_Valid
                and then Initialized,
      Global => (Input    => (Document,
                              Policy),
                 In_Out   => (Gneiss.Syscall.Linux,
                              Proto.Linux),
                 Proof_In => Efd);

   procedure Send_Request (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Name        : String;
                           Label       : String) with
      Pre    => Name'Length + Label'Length < 256,
      Global => (In_Out => Proto.Linux);

   procedure Send_Confirm (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Label       : String;
                           Filedesc    : Integer) with
      Pre    => Label'Length < 256,
      Global => (In_Out => Proto.Linux);

   procedure Send_Reject (Destination : Integer;
                          Kind        : RFLX.Session.Kind_Type;
                          Label       : String) with
      Pre    => Label'Length < 256,
      Global => (In_Out => Proto.Linux);

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
      XML_Buf : String (1 .. 255);
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Index := Positive'Last;
      Valid := False;
      if Name'Last < Name'First then
         return;
      end if;
      for I in Policy'Range loop
         pragma Loop_Invariant (Initialized);
         if Policy (I).Fd > -1 then
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
      Result     : SXML.Parser.Match_Type;
      Ignore_Pos : Natural;
      State      : SXML.Query.State_Type;
      Parent     : Boolean;
   begin
      Gneiss_Log.Info (Config);
      Status := 1;
      Policy := (others => (Fd => -1, Node => SXML.Query.Init (Document => Document), Pid => -1));
      if not SXML.Valid_Content (Config'First, Config'Last) then
         Gneiss_Log.Error ("Invalid content");
         return;
      end if;
      SXML.Parser.Parse (Config, Document, Ignore_Pos, Result);
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
         return;
      end if;
      Gneiss_Epoll.Create (Efd);
      if not Gneiss_Epoll.Valid_Fd (Efd) then
         return;
      end if;
      State := SXML.Query.Init (Document);
      if
         not SXML.Query.Is_Open (State, Document)
      then
         Gneiss_Log.Error ("Init failed");
         return;
      end if;
      Start_Components (State, Parent, Status);
      if Parent and then Valid_Read_Buffer then
         Event_Loop (Status);
      end if;
   end Construct;

   procedure Start_Components (Root   :     SXML.Query.State_Type;
                               Parent : out Boolean;
                               Status : out Integer)
   is
      XML_Buf : String (1 .. 255);
      Pid     : Integer;
      Fd      : Integer;
      Success : Integer;
      Index   : Positive := Policy'First;
      State   : SXML.Query.State_Type;
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Status := 1;
      Parent := True;
      State  := SXML.Query.Path (Root, Document, "/config/component");
      while
         SXML.Query.State_Result (State) = SXML.Result_OK
      loop
         pragma Loop_Invariant (Is_Valid);
         pragma Loop_Invariant (Initialized);
         pragma Loop_Invariant (SXML.Query.Is_Valid (State, Document));
         pragma Loop_Invariant (Index in Policy'Range);
         pragma Loop_Invariant (SXML.Query.Is_Open (State, Document));
         State := SXML.Query.Find_Sibling (State, Document, "component");
         exit when SXML.Query.State_Result (State) /= SXML.Result_OK;
         SXML.Query.Attribute (State, Document, "name", Result, XML_Buf, Last);
         if Result = SXML.Result_OK then
            Gneiss.Syscall.Socketpair (Policy (Index).Fd, Fd);
            if Policy (Index).Fd > -1 then
               Gneiss_Epoll.Add (Efd, Policy (Index).Fd, Index, Success);
               Gneiss.Syscall.Fork (Pid);
               if Pid < 0 then
                  Gneiss_Log.Error ("Fork failed");
                  Policy (Index).Fd := -1;
                  return;
               elsif Pid > 0 then --  parent
                  Policy (Index).Pid  := Pid;
                  Policy (Index).Node := State;
                  pragma Warnings (Off, "unused assignment to ""Fd""");
                  Gneiss.Syscall.Close (Fd);
                  pragma Warnings (On, "unused assignment to ""Fd""");
                  Parent := True;
                  Gneiss_Log.Info ("Started " & XML_Buf (XML_Buf'First .. Last)
                                   & " with PID " & Basalt.Strings.Image (Pid));
               else --  Pid = 0, Child
                  Load (Fd, State, Status);
                  Parent := False;
                  return;
               end if;
            end if;
         else
            Gneiss_Log.Error ("Failed to load component name");
         end if;
         exit when Index = Policy'Last;
         Index := Index + 1;
         State := SXML.Query.Sibling (State, Document);
      end loop;
   end Start_Components;

   procedure Load (Fd   :     Integer;
                   Comp :     SXML.Query.State_Type;
                   Ret  : out Integer)
   is
      Result : SXML.Result_Type;
      Last   : Natural;
   begin
      Ret := 1;
      Gneiss.Syscall.Close (Integer (Efd));
      for I in Policy'Range loop
         pragma Loop_Invariant (Is_Valid);
         Policy (I).Node := SXML.Query.Invalid_State;
         Gneiss.Syscall.Close (Policy (I).Fd);
      end loop;
      SXML.Query.Attribute (Comp, Document, "file", Result, Load_File_Name, Last);
      if Result /= SXML.Result_OK and then Last not in Load_File_Name'Range then
         Gneiss_Log.Error ("No file to load");
         return;
      end if;
      Gneiss.Main.Run (Load_File_Name (Load_File_Name'First .. Last), Fd, Ret);
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
         pragma Loop_Invariant (Is_Valid);
         pragma Loop_Invariant (Initialized);
         pragma Loop_Invariant (Valid_Read_Buffer);
         Gneiss_Epoll.Wait (Efd, Ev, Index);
         if Index in Policy'Range and then Policy (Index).Fd > -1 then
            SXML.Query.Attribute (Policy (Index).Node, Document, "name", Result, XML_Buf, Last);
            if Ev.Epoll_In then
               Read_Message (Index);
            end if;
            if Ev.Epoll_Hup or else Ev.Epoll_Rdhup then
               Gneiss.Syscall.Waitpid (Policy (Index).Pid, Success);
               if Result = SXML.Result_OK then
                  Gneiss_Log.Info ("Component "
                                   & XML_Buf (XML_Buf'First .. Last)
                                   & " exited with status "
                                   & Basalt.Strings.Image (Success));
               else
                  Gneiss_Log.Info ("Component PID "
                                   & Basalt.Strings.Image (Policy (Index).Pid)
                                   & " exited with status "
                                   & Basalt.Strings.Image (Success));
               end if;
               Gneiss_Epoll.Remove (Efd, Policy (Index).Fd, Success);
               Gneiss.Syscall.Close (Policy (Index).Fd);
               Policy (Index).Node := SXML.Query.Init (Document);
               Policy (Index).Pid  := -1;
            end if;
         else
            Gneiss_Log.Warning ("Invalid index");
         end if;
      end loop;
   end Event_Loop;

   procedure Read_Message (Index : Positive)
   is
      Truncated : Boolean;
      Context   : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      Last      : RFLX.Types.Index;
      Fd        : Integer;
   begin
      Gneiss.Main.Peek_Message (Policy (Index).Fd, Read_Buffer.Ptr.all, Last, Truncated, Fd);
      Gneiss.Syscall.Drop_Message (Policy (Index).Fd);
      if Last < Read_Buffer.Ptr.all'First then
         pragma Warnings (Off, "unused assignment to ""Fd""");
         Gneiss.Syscall.Close (Fd);
         pragma Warnings (On, "unused assignment to ""Fd""");
         Gneiss_Log.Warning ("Message too short, dropping");
         return;
      end if;
      if Truncated or else Last > Read_Buffer.Ptr.all'Last then
         pragma Warnings (Off, "unused assignment to ""Fd""");
         Gneiss.Syscall.Close (Fd);
         pragma Warnings (On, "unused assignment to ""Fd""");
         Gneiss_Log.Warning ("Message too large, dropping");
         return;
      end if;
      pragma Warnings (Off, "unused assignment to ""Ptr""");
      RFLX.Session.Packet.Initialize (Context,
                                      Read_Buffer.Ptr,
                                      RFLX.Types.First_Bit_Index (Read_Buffer.Ptr.all'First),
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
         Load_Message (Index, Context, Fd);
      else
         Gneiss_Log.Warning ("Invalid message, dropping");
         pragma Warnings (Off, "unused assignment to ""Fd""");
         Gneiss.Syscall.Close (Fd);
         pragma Warnings (On, "unused assignment to ""Fd""");
      end if;
      pragma Warnings (Off, "unused assignment to ""Context""");
      RFLX.Session.Packet.Take_Buffer (Context, Read_Buffer.Ptr);
      pragma Warnings (On, "unused assignment to ""Context""");
   end Read_Message;

   procedure Load_Message (Index   : Positive;
                           Context : RFLX.Session.Packet.Context;
                           Fd      : Integer)
   is
      use type RFLX.Session.Length_Type;
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
         Handle_Message (Index,
                         RFLX.Session.Packet.Get_Action (Context),
                         RFLX.Session.Packet.Get_Kind (Context),
                         Load_Message_Name (Load_Message_Name'First .. Name_Last),
                         Load_Message_Label (Load_Message_Label'First .. Label_Last),
                         Fd);
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
            if Label'Length >= 256 then
               Gneiss_Log.Warning ("Cannot process request");
               return;
            end if;
            Process_Request (Source, Kind, Label);
         when RFLX.Session.Confirm =>
            if Name'Length + Label'Length >= 256 then
               Gneiss_Log.Warning ("Cannot process confirm");
               return;
            end if;
            Process_Confirm (Kind, Name, Label, Fd);
         when RFLX.Session.Reject =>
            if Name'Length + Label'Length >= 256 then
               Gneiss_Log.Warning ("Cannot process reject");
               return;
            end if;
            Process_Reject (Kind, Name, Label);
      end case;
   end Handle_Message;

   procedure Process_Request (Source : Positive;
                              Kind   : RFLX.Session.Kind_Type;
                              Label  : String)
   is
      XML_Buf     : String (1 .. 255);
      State       : SXML.Query.State_Type;
      Destination : Positive;
      Valid       : Boolean;
      Result      : SXML.Result_Type;
      Last        : Natural;
      Found       : Boolean               := False;
      Dest_State  : SXML.Query.State_Type := SXML.Query.Invalid_State;
   begin
      if Policy (Source).Fd < 0 then
         Gneiss_Log.Warning ("Cannot process invalid source");
         return;
      end if;
      State := SXML.Query.Child (Policy (Source).Node, Document);
      while
         SXML.Query.State_Result (State) = SXML.Result_OK
      loop
         pragma Loop_Invariant (Is_Valid);
         pragma Loop_Invariant (Initialized);
         pragma Loop_Invariant (SXML.Query.Is_Valid (State, Document));
         pragma Loop_Invariant (SXML.Query.State_Result (State) = SXML.Result_OK);
         pragma Loop_Invariant (SXML.Query.Is_Open (State, Document)
                                or else SXML.Query.Is_Content (State, Document));
         pragma Loop_Invariant (if Found then (SXML.Query.Is_Valid (Dest_State, Document)
                                               and then SXML.Query.State_Result (Dest_State) = SXML.Result_OK
                                               and then SXML.Query.Is_Open (Dest_State, Document)));
         State := SXML.Query.Find_Sibling (State, Document, "service", "name", Proto.Image (Kind));
         exit when SXML.Query.State_Result (State) /= SXML.Result_OK;
         SXML.Query.Attribute (State, Document, "label", Result, XML_Buf, Last);
         if
            Result = SXML.Result_OK
            and then Label'Length > 0
            and then Last - XML_Buf'First = Label'Last - Label'First
            and then XML_Buf (XML_Buf'First .. Last) = Label
         then
            --  if an exact label match was found, stop
            --  pragma Assert (SXML.Query.State_Result (State) = SXML.Result_OK);
            Dest_State := State;
            Found      := True;
            exit;
         elsif Result = SXML.Result_Not_Found then
            --  if a default service w/o label was found,
            --  continue in case the exact label exists
            Dest_State := State;
            Found      := True;
         end if;
         State := SXML.Query.Sibling (State, Document);
      end loop;
      if not Found then
         Gneiss_Log.Error ("No service found");
         Send_Reject (Policy (Source).Fd, Kind, Label);
         return;
      end if;
      SXML.Query.Attribute (Dest_State, Document, "server", Result, XML_Buf, Last);
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
      if Last - XML_Buf'First + 1 + Label'Length < 256 then
         Send_Request (Policy (Destination).Fd, Kind, XML_Buf (XML_Buf'First .. Last), Label);
      else
         Gneiss_Log.Warning ("Failed to send request");
      end if;
   end Process_Request;

   procedure Process_Confirm (Kind  : RFLX.Session.Kind_Type;
                              Name  : String;
                              Label : String;
                              Fd    : Integer)
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

   procedure Process_Reject (Kind  : RFLX.Session.Kind_Type;
                             Name  : String;
                             Label : String)
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
