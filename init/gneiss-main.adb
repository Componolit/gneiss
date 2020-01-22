
with Basalt.Queue;
with Gneiss_Access;
with Gneiss_Internal.Message;
with Gneiss.Protocol;
with Gneiss_Platform;
with Gneiss_Log;
with System;
with RFLX.Session;
with RFLX.Session.Packet;

package body Gneiss.Main with
SPARK_Mode,
   Refined_State => (Component_State => (Component_Status,
                                         Epoll_Fd,
                                         Broker_Fd,
                                         Services,
                                         Initializers,
                                         Requests,
                                         Read_Label,
                                         Read_Name,
                                         Read_Buffer.Ptr,
                                         Proto.Linux,
                                         Session,
                                         Event_Cap))
is
   use type Gneiss_Epoll.Epoll_Fd;
   use type System.Address;
   use type RFLX.Types.Bytes_Ptr;

   type Service_Registry is array (RFLX.Session.Kind_Type'Range) of Gneiss_Platform.Dispatcher_Cap;
   type Initializer_Registry is array (Positive range <>) of Gneiss_Platform.Initializer_Cap;
   type Initializer_Service_Registry is array (RFLX.Session.Kind_Type'Range) of Initializer_Registry (1 .. 10);
   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   type Request_Cache is record
      Name   : String (1 .. 255)                := (others => Character'First);
      Label  : String (1 .. 255)                := (others => Character'First);
      N_Last : Natural                          := 0;
      L_Last : Natural                          := 0;
      Fds    : Gneiss_Syscall.Fd_Array (1 .. 2) := (others => -1);
   end record;
   type Dummy_Session is limited null record;
   package Queue is new Basalt.Queue (Request_Cache);
   type Request_Registry is array (RFLX.Session.Kind_Type'Range) of Queue.Context (10);

   package Read_Buffer is new Gneiss_Access (512);

   package Proto is new Gneiss.Protocol (Character, RFLX_String);

   function Create_Cap (Fd : Integer) return Capability with
      Global => (Input => Epoll_Fd);
   procedure Set_Status (S : Integer) with
      Global => (Output => Component_Status);
   function Set_Status_Cap is new Gneiss_Platform.Create_Set_Status_Cap (Set_Status);
   procedure Event_Handler with
      Global => (Input  => Epoll_Fd,
                 In_Out => Gneiss_Epoll.Linux),
      Pre => Gneiss_Epoll.Valid_Fd (Epoll_Fd),
      Post => Gneiss_Epoll.Valid_Fd (Epoll_Fd);
   procedure Call_Event (Fp : System.Address) with
      Pre    => Fp /= System.Null_Address,
      Global => (Input  => Broker_Fd,
                 In_Out => (Services,
                            Initializers,
                            Requests,
                            Proto.Linux),
                 Output => Component_Status);

   procedure Register_Service (Kind :     RFLX.Session.Kind_Type;
                               Cap  :     Gneiss_Platform.Dispatcher_Cap;
                               Succ : out Boolean) with
      Global => (In_Out => Services);
   procedure Register_Initializer (Kind :     RFLX.Session.Kind_Type;
                                   Cap  :     Gneiss_Platform.Initializer_Cap;
                                   Succ : out Boolean) with
      Global => (Input  => (Broker_Fd, Services),
                 In_Out => (Initializers, Requests, Proto.Linux));
   function Register_Service_Cap is new Gneiss_Platform.Create_Register_Service_Cap
      (Register_Service);
   function Register_Initializer_Cap is new Gneiss_Platform.Create_Register_Initializer_Cap
      (Register_Initializer);

   procedure Construct (Symbol : System.Address;
                        Cap    : Capability) with
      Global => (Input  => Broker_Fd,
                 In_Out => (Services,
                            Initializers,
                            Requests,
                            Proto.Linux),
                 Output => Component_Status);
   procedure Destruct (Symbol : System.Address) with
      Global => (Input  => Broker_Fd,
                 In_Out => (Services,
                            Initializers,
                            Requests,
                            Proto.Linux),
                 Output => Component_Status);
   procedure Broker_Event (D : in out Dummy_Session) with
      Global => (Input  => (Services,
                            Broker_Fd),
                 In_Out => (Read_Buffer.Ptr,
                            Read_Label,
                            Proto.Linux,
                            Initializers,
                            Requests,
                            Read_Name,
                            Gneiss_Syscall.Linux)),
      Pre => Read_Buffer.Ptr /= null,
      Post => Read_Buffer.Ptr /= null;
   function Broker_Event_Cap is new Gneiss_Platform.Create_Event_Cap (Dummy_Session, Broker_Event);
   procedure Handle_Answer (Kind  : RFLX.Session.Kind_Type;
                            Fd    : Gneiss_Syscall.Fd_Array;
                            Label : String) with
      Global => (In_Out => Initializers);
   procedure Load_Message (Context    :     RFLX.Session.Packet.Context;
                           Label      : out String;
                           Last_Label : out Natural;
                           Name       : out String;
                           Last_Name  : out Natural) with
      Global => null,
      Pre => Name'First = 1
      and then Name'Length > 254
      and then Label'First = 1
      and then Label'Length > 254
      and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length)
      and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Payload_Length),
      Post => Last_Label in Label'Range
      and then Last_Name in Name'Range;
   procedure Handle_Requests with
      Global => (Input  => (Broker_Fd, Services),
                 In_Out => (Requests, Proto.Linux));
   procedure Dispatch_Service (Kind     :     RFLX.Session.Kind_Type;
                               Accepted : out Boolean) with
      Pre => Gneiss_Platform.Is_Valid (Services (Kind)),
      Global => (Input  => (Broker_Fd, Services, Requests),
                 In_Out => Proto.Linux);
   procedure Reject_Request (Kind : RFLX.Session.Kind_Type) with
      Global => (Input  => Broker_Fd,
                 In_Out => (Proto.Linux, Requests));
   function Broker_Event_Address return System.Address with
      Global => (Input => Event_Cap);

   Running : constant Integer := -1;
   Success : constant Integer := 0;
   Failure : constant Integer := 1;

   Component_Status : Integer               := Running;
   Epoll_Fd         : Gneiss_Epoll.Epoll_Fd := -1;
   Broker_Fd        : Integer               := -1;
   Services         : Service_Registry;
   Initializers     : Initializer_Service_Registry;
   Requests         : Request_Registry;
   Read_Name        : String (1 .. 255) := (others => Character'First);
   Read_Label       : String (1 .. 255) := (others => Character'First);
   Session          : constant Dummy_Session    := (null record);
   Event_Cap        : Gneiss_Platform.Event_Cap := Broker_Event_Cap (Session);

   procedure Message_Initializer is new Gneiss_Platform.Initializer_Call (Gneiss_Internal.Message.Client_Session);
   procedure Message_Dispatcher is new Gneiss_Platform.Dispatcher_Call (Gneiss_Internal.Message.Dispatcher_Session);

   function Broker_Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event_Cap'Address;
   end Broker_Event_Address;

   procedure Call_Event (Fp : System.Address)
   is
      Cap : Gneiss_Platform.Event_Cap with
         Import,
         Address => Fp;
   begin
      Gneiss_Platform.Call (Cap);
   end Call_Event;

   procedure Register_Service (Kind :     RFLX.Session.Kind_Type;
                               Cap  :     Gneiss_Platform.Dispatcher_Cap;
                               Succ : out Boolean)
   is
   begin
      if
         not Gneiss_Platform.Is_Valid (Cap)
         or else Gneiss_Platform.Is_Valid (Services (Kind))
      then
         Succ := False;
      else
         Services (Kind) := Cap;
         Succ := True;
      end if;
   end Register_Service;

   procedure Register_Initializer (Kind :     RFLX.Session.Kind_Type;
                                   Cap  :     Gneiss_Platform.Initializer_Cap;
                                   Succ : out Boolean)
   is
   begin
      Succ := False;
      if not Gneiss_Platform.Is_Valid (Cap) then
         return;
      end if;
      for I in Initializers (Kind)'Range loop
         if not Gneiss_Platform.Is_Valid (Initializers (Kind)(I)) then
            Initializers (Kind)(I) := Cap;
            Succ := True;
            Handle_Requests;
            return;
         end if;
      end loop;
   end Register_Initializer;

   procedure Run (Name   :     String;
                  Fd     :     Integer;
                  Status : out Integer)
   is
      use type Gneiss.Linker.Dl_Handle;
      Handle        : Gneiss.Linker.Dl_Handle;
      Construct_Sym : System.Address;
      Destruct_Sym  : System.Address;
   begin
      Broker_Fd := Fd;
      Gneiss.Linker.Open (Name, Handle);
      if Handle = Gneiss.Linker.Invalid_Handle then
         Gneiss_Log.Error ("Linker handle failed");
         Status := 1;
         return;
      end if;
      Construct_Sym := Gneiss.Linker.Symbol (Handle, "component__construct");
      Destruct_Sym  := Gneiss.Linker.Symbol (Handle, "component__destruct");
      if
         Construct_Sym = System.Null_Address
         or else Destruct_Sym = System.Null_Address
      then
         Gneiss_Log.Error ("Linker symbols failed");
         Status := 1;
         return;
      end if;
      Gneiss_Epoll.Create (Epoll_Fd);
      if Epoll_Fd < 0 then
         Gneiss_Log.Error ("Epoll creation failed");
         Status := 1;
         return;
      end if;
      Gneiss_Epoll.Add (Epoll_Fd, Broker_Fd, Broker_Event_Address, Status);
      if Status /= 0 then
         Gneiss_Log.Error ("Failed to add epoll fd");
         Status := 1;
         return;
      end if;
      Construct (Construct_Sym, Create_Cap (Fd));
      while Component_Status = Running loop
         Event_Handler;
      end loop;
      Destruct (Destruct_Sym);
      Status := Component_Status;
   end Run;

   procedure Event_Handler
   is
      Event_Ptr : System.Address;
      Event     : Gneiss_Epoll.Event;
   begin
      Gneiss_Epoll.Wait (Epoll_Fd, Event, Event_Ptr);
      if Event.Epoll_Hup or else Event.Epoll_Rdhup then
         Gneiss_Log.Error ("Socket closed unexpectedly, shutting down");
         raise Program_Error;
      end if;
      if Event.Epoll_In then
         if Event_Ptr /= System.Null_Address then
            Call_Event (Event_Ptr);
         end if;
      end if;
   end Event_Handler;

   procedure Broker_Event (D : in out Dummy_Session)
   is
      pragma Unreferenced (D);
      use type RFLX.Types.Length;
      Truncated  : Boolean;
      Context    : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      Last       : RFLX.Types.Index;
      Fd         : Gneiss_Syscall.Fd_Array (1 .. 2);
      Name_Last  : Natural;
      Label_Last : Natural;
      Kind       : RFLX.Session.Kind_Type;
      procedure Load_Entry (E : out Request_Cache) with
         Global => (In_Out => Context);
      procedure Put is new Queue.Generic_Put (Load_Entry);
      procedure Load_Entry (E : out Request_Cache)
      is
      begin
         E.Fds := Fd;
         Load_Message (Context, E.Label, E.L_Last, E.Name, E.N_Last);
      end Load_Entry;
   begin
      Peek_Message (Broker_Fd, Read_Buffer.Ptr.all, Last, Truncated, Fd);
      Gneiss_Syscall.Drop_Message (Broker_Fd);
      if Last < Read_Buffer.Ptr.all'First then
         pragma Warnings (Off, "unused assignment to ""Fd""");
         for Filedesc of Fd loop
            Gneiss_Syscall.Close (Filedesc);
         end loop;
         pragma Warnings (On, "unused assignment to ""Fd""");
         Gneiss_Log.Warning ("Message too short, dropping");
         return;
      end if;
      if Truncated or else Last > Read_Buffer.Ptr.all'Last then
         pragma Warnings (Off, "unused assignment to ""Fd""");
         for Filedesc of Fd loop
            Gneiss_Syscall.Close (Filedesc);
         end loop;
         pragma Warnings (On, "unused assignment to ""Fd""");
         Gneiss_Log.Warning ("Message too large, dropping");
         return;
      end if;
      if Truncated then
         return;
      end if;
      RFLX.Session.Packet.Initialize (Context, Read_Buffer.Ptr,
                                      RFLX.Types.First_Bit_Index (Read_Buffer.Ptr.all'First),
                                      RFLX.Types.Last_Bit_Index (Last));
      pragma Assert (RFLX.Session.Packet.Has_Buffer (Context));
      RFLX.Session.Packet.Verify_Message (Context);
      pragma Assert (RFLX.Session.Packet.Has_Buffer (Context));
      if
         RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Action)
         and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Kind)
         and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length)
         and then RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Payload_Length)
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload)
      then
         Kind := RFLX.Session.Packet.Get_Kind (Context);
         case RFLX.Session.Packet.Get_Action (Context) is
            when RFLX.Session.Request =>
               if Queue.Count (Requests (Kind)) >= Queue.Size (Requests (Kind)) then
                  Reject_Request (Kind);
               end if;
               Put (Requests (Kind));
               pragma Assert (RFLX.Session.Packet.Has_Buffer (Context));
            when RFLX.Session.Confirm | RFLX.Session.Reject =>
               Load_Message (Context, Read_Label, Label_Last, Read_Name, Name_Last);
               Handle_Answer (Kind, Fd, Read_Label (Read_Label'First .. Label_Last));
         end case;
      end if;
      pragma Assert (RFLX.Session.Packet.Has_Buffer (Context));
      RFLX.Session.Packet.Take_Buffer (Context, Read_Buffer.Ptr);
      Handle_Requests;
   end Broker_Event;

   procedure Handle_Answer (Kind  : RFLX.Session.Kind_Type;
                            Fd    : Gneiss_Syscall.Fd_Array;
                            Label : String)
   is
   begin
      for I of Initializers (Kind) loop
         if Gneiss_Platform.Is_Valid (I) then
            case Kind is
               when RFLX.Session.Message =>
                  Message_Initializer (I, Label, Fd (Fd'First) >= 0, Fd (Fd'First));
               when RFLX.Session.Log =>
                  Message_Initializer (I, Label, Fd (Fd'First) >= 0, Fd (Fd'First));
               when RFLX.Session.Memory | RFLX.Session.Rom =>
                  null;
            end case;
            Gneiss_Platform.Invalidate (I);
         end if;
      end loop;
   end Handle_Answer;

   procedure Dispatch_Service (Kind     :     RFLX.Session.Kind_Type;
                               Accepted : out Boolean)
   is
      procedure Peek (E : Request_Cache);
      procedure Peek is new Queue.Generic_Peek (Peek);
      procedure Peek (E : Request_Cache)
      is
         Fd    : Gneiss_Syscall.Fd_Array (1 .. 2) := E.Fds;
         Name  : RFLX_String (1 .. RFLX.Session.Length_Type (E.N_Last));
         Label : RFLX_String (1 .. RFLX.Session.Length_Type (E.L_Last));
         Index : Positive := E.Name'First;
         Num   : Natural;
      begin
         Message_Dispatcher (Services (Kind),
                             E.Name (E.Name'First .. E.N_Last),
                             E.Label (E.Label'First .. E.L_Last),
                             Fd, Num);
         Accepted := Num > 0;
         if not Accepted then
            return;
         end if;
         for C of Name loop
            C := E.Name (Index);
            exit when Index = E.N_Last or else Index = E.Name'Last;
            Index := Index + 1;
         end loop;
         Index := E.Label'First;
         for C of Label loop
            C := E.Label (Index);
            exit when Index = E.L_Last or else Index = E.Label'Last;
            Index := Index + 1;
         end loop;
         Proto.Send_Message (Broker_Fd,
                             Proto.Message'(Length      => RFLX.Session.Length_Type (E.N_Last + E.L_Last),
                                            Action      => RFLX.Session.Confirm,
                                            Kind        => Kind,
                                            Name_Length => RFLX.Session.Length_Type (E.N_Last),
                                            Payload     => Name & Label),
                             Fd (Fd'First .. Fd'First + Num - 1));
      end Peek;
   begin
      Peek (Requests (Kind));
   end Dispatch_Service;

   procedure Handle_Requests
   is
      Accepted : Boolean;
   begin
      for Kind in RFLX.Session.Kind_Type'Range loop
         if Gneiss_Platform.Is_Valid (Services (Kind)) then
            while Queue.Count (Requests (Kind)) > 0 loop
               Dispatch_Service (Kind, Accepted);
               exit when not Accepted;
               Queue.Drop (Requests (Kind));
            end loop;
         end if;
      end loop;
   end Handle_Requests;

   function Create_Cap (Fd : Integer) return Capability is
      (Capability'(Broker_Fd            => Fd,
                   Set_Status           => Set_Status_Cap,
                   Register_Service     => Register_Service_Cap,
                   Register_Initializer => Register_Initializer_Cap,
                   Epoll_Fd             => Epoll_Fd));

   procedure Load_Message (Context    :     RFLX.Session.Packet.Context;
                           Label      : out String;
                           Last_Label : out Natural;
                           Name       : out String;
                           Last_Name  : out Natural)
   is
      use type RFLX.Types.Length;
      use type RFLX.Session.Length_Type;
      Length     : constant RFLX.Types.Length := RFLX.Types.Length (RFLX.Session.Packet.Get_Name_Length (Context));
      Name_Last  : constant Natural           := Natural (RFLX.Session.Packet.Get_Name_Length (Context));
      Label_Last : constant Natural           := Natural (RFLX.Session.Packet.Get_Payload_Length (Context) -
                                                 RFLX.Session.Packet.Get_Name_Length (Context));
      procedure Process_Payload (Payload : RFLX.Types.Bytes) with
         Pre => Length < 256
         and then Payload'First < RFLX.Types.Length'Last - 512
         and then Payload'First <= Payload'Last
         and then Name'First = 1
         and then Name'Length > 254
         and then Label'First = 1
         and then Label'Last > 254;
      procedure Get_Payload is new RFLX.Session.Packet.Get_Payload (Process_Payload);
      procedure Process_Payload (Payload : RFLX.Types.Bytes)
      is
         Index       : RFLX.Types.Length;
         Offset      : Natural;
      begin
         for I in Name'First .. Name_Last loop
            pragma Loop_Invariant (Name'First = 1);
            pragma Loop_Invariant (Name'Length > 254);
            Offset := I - Name'First;
            Index  := Payload'First + RFLX.Types.Length (Offset);
            if Index in Payload'Range then
               Name (Name'First + Offset) := Character'Val (Payload (Index));
            else
               Name (Name'First + Offset) := Character'First;
            end if;
         end loop;
         for I in Label'First .. Label_Last loop
            pragma Loop_Invariant (Label'First = 1);
            pragma Loop_Invariant (Label'Length > 254);
            Offset := I - Label'First;
            Index  := Payload'First + RFLX.Types.Length (Name_Last + Offset);
            if Index in Payload'Range then
               Label (Label'First + Offset) := Character'Val (Payload (Index));
            else
               Label (Label'First + Offset) := Character'First;
            end if;
         end loop;
      end Process_Payload;
   begin
      Last_Name  := (if Name_Last > 0 then Name_Last else Name'First);
      Last_Label := (if Label_Last > 0 then Label_Last else Label'First);
      Label := (others => Character'First);
      Name := (others => Character'First);
      if
         RFLX.Session.Packet.Has_Buffer (Context)
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Payload)
      then
         Get_Payload (Context);
      end if;
   end Load_Message;

   procedure Set_Status (S : Integer)
   is
   begin
      Component_Status := (if S = 0 then Success else Failure);
   end Set_Status;

   procedure Construct (Symbol : System.Address;
                        Cap    : Capability)
   is
      procedure Component_Construct (C : Capability) with
         Import,
         Address => Symbol,
         Global  => (Input  => Broker_Fd,
                     In_Out => (Services,
                                Initializers,
                                Requests,
                                Proto.Linux),
                     Output => Component_Status);
   begin
      Component_Construct (Cap);
   end Construct;

   procedure Destruct (Symbol : System.Address)
   is
      procedure Component_Destruct with
         Import,
         Address => Symbol,
         Global  => (Input  => Broker_Fd,
                     In_Out => (Services,
                                Initializers,
                                Requests,
                                Proto.Linux),
                     Output => Component_Status);
   begin
      Component_Destruct;
   end Destruct;

   procedure Peek_Message (Socket    :     Integer;
                           Message   : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean;
                           Fd        : out Gneiss_Syscall.Fd_Array) with
      SPARK_Mode => Off
   is
      use type RFLX.Types.Index;
      Trunc     : Integer;
      Length    : Integer;
   begin
      Gneiss_Syscall.Peek_Message (Socket, Message'Address, Message'Length, Fd, Fd'Length, Length, Trunc);
      Truncated := Trunc = 1;
      if Length < 1 then
         Last := RFLX.Types.Index'First;
         return;
      end if;
      Last := (Message'First + RFLX.Types.Index (Length)) - 1;
   end Peek_Message;

   procedure Reject_Request (Kind : RFLX.Session.Kind_Type)
   is
      procedure Pop (E : Request_Cache);
      procedure Pop is new Queue.Generic_Pop (Pop);
      procedure Pop (E : Request_Cache)
      is
         Name  : RFLX_String (1 .. RFLX.Session.Length_Type (E.N_Last));
         Label : RFLX_String (1 .. RFLX.Session.Length_Type (E.L_Last));
         Index : Positive := E.Name'First;
      begin
         for C of Name loop
            C := E.Name (Index);
            exit when Index = E.N_Last or else Index = E.Name'Last;
            Index := Index + 1;
         end loop;
         Index := E.Label'First;
         for C of Label loop
            C := E.Label (Index);
            exit when Index = E.L_Last or else Index = E.Label'Last;
            Index := Index + 1;
         end loop;
         Proto.Send_Message (Broker_Fd,
                             Proto.Message'(Length      => RFLX.Session.Length_Type (E.N_Last + E.L_Last),
                                            Action      => RFLX.Session.Reject,
                                            Kind        => Kind,
                                            Name_Length => RFLX.Session.Length_Type (E.N_Last),
                                            Payload     => Name & Label));
      end Pop;
   begin
      Pop (Requests (Kind));
   end Reject_Request;

end Gneiss.Main;
