
with Ada.Unchecked_Conversion;
with Basalt.Strings;
with Basalt.Queue;
with Gneiss.Linker;
with Gneiss_Internal.Message;
with Gneiss.Protocoll;
with Gneiss.Syscall;
with Gneiss_Epoll;
with Gneiss_Platform;
with System;
with Componolit.Runtime.Debug;
with RFLX.Session;
with RFLX.Session.Packet;

package body Gneiss.Main with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;
   use type System.Address;

   type Service_Registry is array (RFLX.Session.Kind_Type'Range) of Gneiss_Platform.Dispatcher_Cap;
   type Initializer_Registry is array (Positive range <>) of Gneiss_Platform.Initializer_Cap;
   type Initializer_Service_Registry is array (RFLX.Session.Kind_Type'Range) of Initializer_Registry (1 .. 10);
   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   type Request_Cache is record
      Name   : String (1 .. 255)   := (others => Character'First);
      Label  : String (1 .. 255)   := (others => Character'First);
      N_Last : Natural := 0;
      L_Last : Natural := 0;
   end record;
   package Queue is new Basalt.Queue (Request_Cache);
   type Request_Registry is array (RFLX.Session.Kind_Type'Range) of Queue.Context (10);

   package Proto is new Gneiss.Protocoll (Character, RFLX_String);

   function Create_Cap (Fd : Integer) return Capability;
   procedure Set_Status (S : Integer);
   function Set_Status_Cap is new Gneiss_Platform.Create_Set_Status_Cap (Set_Status);
   procedure Event_Handler;
   procedure Call_Event (Fp : System.Address) with
      Pre => Fp /= System.Null_Address;

   procedure Register_Service (Kind :     RFLX.Session.Kind_Type;
                               Cap  :     Gneiss_Platform.Dispatcher_Cap;
                               Succ : out Boolean);
   procedure Register_Initializer (Kind :     RFLX.Session.Kind_Type;
                                   Cap  :     Gneiss_Platform.Initializer_Cap;
                                   Succ : out Boolean);
   function Register_Service_Cap is new Gneiss_Platform.Create_Register_Service_Cap
      (Register_Service);
   function Register_Initializer_Cap is new Gneiss_Platform.Create_Register_Initializer_Cap
      (Register_Initializer);

   procedure Construct (Symbol : System.Address;
                        Cap    : Capability);
   procedure Destruct (Symbol : System.Address);
   procedure Broker_Event;
   function Broker_Event_Address return System.Address;
   procedure Handle_Answer (Kind  : RFLX.Session.Kind_Type;
                            Fd    : Integer;
                            Label : String);
   procedure Load_Message (Context    : in out RFLX.Session.Packet.Context;
                           Label      :    out String;
                           Last_Label :    out Natural;
                           Name       :    out String;
                           Last_Name  :    out Natural);
   procedure Handle_Requests;
   procedure Dispatch_Service (Kind     :     RFLX.Session.Kind_Type;
                               Accepted : out Boolean) with
      Pre => Gneiss_Platform.Is_Valid (Services (Kind));
   procedure Reject_Request (Kind : RFLX.Session.Kind_Type);

   Running : constant Integer := -1;
   Success : constant Integer := 0;
   Failure : constant Integer := 1;

   Component_Status : Integer               := Running;
   Epoll_Fd         : Gneiss_Epoll.Epoll_Fd := -1;
   Broker_Fd        : Integer               := -1;
   Services         : Service_Registry;
   Initializers     : Initializer_Service_Registry;
   Requests         : Request_Registry;

   procedure Message_Initializer is new Gneiss_Platform.Initializer_Call (Gneiss_Internal.Message.Client_Session);
   procedure Message_Dispatcher is new Gneiss_Platform.Dispatcher_Call (Gneiss_Internal.Message.Dispatcher_Session);

   procedure Call_Event (Fp : System.Address)
   is
      procedure Event with
         Import,
         Address => Fp;
   begin
      Event;
   end Call_Event;

   procedure Register_Service (Kind    :     RFLX.Session.Kind_Type;
                               Cap     :     Gneiss_Platform.Dispatcher_Cap;
                               Succ    : out Boolean)
   is
   begin
      Componolit.Runtime.Debug.Log_Debug ("Registering...");
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
            return;
         end if;
      end loop;
   end Register_Initializer;

   procedure Run (Name       :     String;
                  Fd         :     Integer;
                  Status     : out Integer)
   is
      use type Gneiss.Linker.Dl_Handle;
      Handle        : Gneiss.Linker.Dl_Handle;
      Construct_Sym : System.Address;
      Destruct_Sym  : System.Address;
   begin
      Broker_Fd := Fd;
      Componolit.Runtime.Debug.Log_Debug ("Main: " & Name);
      Gneiss.Linker.Open (Name, Handle);
      if Handle = Gneiss.Linker.Invalid_Handle then
         Componolit.Runtime.Debug.Log_Error ("Linker handle failed");
         Status := 1;
         return;
      end if;
      Construct_Sym := Gneiss.Linker.Symbol (Handle, "component__construct");
      Destruct_Sym  := Gneiss.Linker.Symbol (Handle, "component__destruct");
      if
         Construct_Sym = System.Null_Address
         or else Destruct_Sym = System.Null_Address
      then
         Componolit.Runtime.Debug.Log_Error ("Linker symbols failed");
         Status := 1;
         return;
      end if;
      Gneiss_Epoll.Create (Epoll_Fd);
      if Epoll_Fd < 0 then
         Componolit.Runtime.Debug.Log_Error ("Epoll creation failed");
         Status := 1;
         return;
      end if;
      Gneiss_Epoll.Add (Epoll_Fd, Broker_Fd, Broker_Event_Address, Status);
      if Status /= 0 then
         Componolit.Runtime.Debug.Log_Error ("Failed to add epoll fd");
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
         Componolit.Runtime.Debug.Log_Error ("Socket closed unexpectedly, shutting down");
         raise Program_Error;
      end if;
      if Event.Epoll_In then
         Componolit.Runtime.Debug.Log_Debug ("Received event");
         if Event_Ptr /= System.Null_Address then
            Componolit.Runtime.Debug.Log_Debug ("Call event");
            Call_Event (Event_Ptr);
         end if;
      end if;
   end Event_Handler;

   type Bytes_Ptr is access all RFLX.Types.Bytes;
   function Convert is new Ada.Unchecked_Conversion (Bytes_Ptr, RFLX.Types.Bytes_Ptr);
   Read_Buffer : aliased RFLX.Types.Bytes := (1 .. 512 => 0);

   Read_Name  : String (1 .. 255);
   Read_Label : String (1 .. 255);

   procedure Broker_Event
   is
      Truncated  : Boolean;
      Context    : RFLX.Session.Packet.Context;
      Buffer_Ptr : RFLX.Types.Bytes_Ptr := Convert (Read_Buffer'Access);
      Last       : RFLX.Types.Index;
      Fd         : Integer;
      Name_Last  : Natural;
      Label_Last : Natural;
      Kind       : RFLX.Session.Kind_Type;
      procedure Load_Entry (E : out Request_Cache);
      procedure Put is new Queue.Generic_Put (Load_Entry);
      procedure Load_Entry (E : out Request_Cache)
      is
      begin
         Load_Message (Context, E.Label, E.L_Last, E.Name, E.N_Last);
      end Load_Entry;
   begin
      Componolit.Runtime.Debug.Log_Debug ("Broker_Event");
      Peek_Message (Broker_Fd, Read_Buffer, Last, Truncated, Fd);
      Gneiss.Syscall.Drop_Message (Broker_Fd);
      if Truncated then
         return;
      end if;
      RFLX.Session.Packet.Initialize (Context, Buffer_Ptr,
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
         Componolit.Runtime.Debug.Log_Warning ("Invalid message, dropping");
         return;
      end if;
      Kind := RFLX.Session.Packet.Get_Kind (Context);
      case RFLX.Session.Packet.Get_Action (Context) is
         when RFLX.Session.Request =>
            Componolit.Runtime.Debug.Log_Debug ("Request");
            if Queue.Count (Requests (Kind)) >= Queue.Size (Requests (Kind)) then
               Reject_Request (Kind);
            end if;
            Put (Requests (Kind));
         when RFLX.Session.Confirm =>
            Componolit.Runtime.Debug.Log_Debug ("Confirm");
            Load_Message (Context, Read_Label, Label_Last, Read_Name, Name_Last);
            Handle_Answer (Kind, Fd, Read_Label (Read_Label'First .. Label_Last));
         when RFLX.Session.Reject =>
            Componolit.Runtime.Debug.Log_Debug ("Reject");
            Load_Message (Context, Read_Label, Label_Last, Read_Name, Name_Last);
            Handle_Answer (Kind, Fd, Read_Label (Read_Label'First .. Label_Last));
      end case;
      Handle_Requests;
   end Broker_Event;

   procedure Handle_Answer (Kind  : RFLX.Session.Kind_Type;
                            Fd    : Integer;
                            Label : String)
   is
   begin
      Componolit.Runtime.Debug.Log_Debug ("Handle_Answer " & Basalt.Strings.Image (Fd));
      for I of Initializers (Kind) loop
         if Gneiss_Platform.Is_Valid (I) then
            Componolit.Runtime.Debug.Log_Debug ("Initialize with Answer " & Label);
            case Kind is
               when RFLX.Session.Message =>
                  Message_Initializer (I, Label, Fd >= 0, Fd);
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
         Fd    : Integer := -1;
         Name  : RFLX_String (1 .. RFLX.Session.Length_Type (E.N_Last));
         Label : RFLX_String (1 .. RFLX.Session.Length_Type (E.L_Last));
         Index : Positive := E.Name'First;
      begin
         Message_Dispatcher (Services (Kind),
                             E.Name (E.Name'First .. E.N_Last),
                             E.Label (E.Label'First .. E.L_Last),
                             Fd);
         Accepted := Fd >= 0;
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
                             Fd);
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

   function Broker_Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Broker_Event'Address;
   end Broker_Event_Address;

   function Create_Cap (Fd : Integer) return Capability is
      (Capability'(Broker_Fd            => Fd,
                   Set_Status           => Set_Status_Cap,
                   Register_Service     => Register_Service_Cap,
                   Register_Initializer => Register_Initializer_Cap,
                   Epoll_Fd             => Epoll_Fd));

   procedure Load_Message (Context    : in out RFLX.Session.Packet.Context;
                           Label      :    out String;
                           Last_Label :    out Natural;
                           Name       :    out String;
                           Last_Name  :    out Natural)
   is
      procedure Process_Payload (Payload : RFLX.Types.Bytes);
      procedure Get_Payload is new RFLX.Session.Packet.Get_Payload (Process_Payload);
      procedure Process_Payload (Payload : RFLX.Types.Bytes)
      is
         use type RFLX.Types.Length;
         Label_First : constant RFLX.Types.Length :=
            Payload'First + RFLX.Types.Length (RFLX.Session.Packet.Get_Name_Length (Context));
         Index       : RFLX.Types.Length := Payload'First;
      begin
         for I in Name'Range loop
            exit when Index = Label_First;
            Name (I)  := Character'Val (Payload (Index));
            Index     := Index + 1;
            Last_Name := I;
         end loop;
         for I in Label'Range loop
            Label (I)  := Character'Val (Payload (Index));
            Last_Label := I;
            exit when Index = Payload'Last;
            Index      := Index + 1;
         end loop;
      end Process_Payload;
   begin
      Last_Name  := 0;
      Last_Label := 0;
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
         Address => Symbol;
   begin
      Component_Construct (Cap);
   end Construct;

   procedure Destruct (Symbol : System.Address)
   is
      procedure Component_Destruct with
         Import,
         Address => Symbol;
   begin
      Component_Destruct;
   end Destruct;

   procedure Peek_Message (Socket    :     Integer;
                           Message   : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean;
                           Fd        : out Integer) with
      SPARK_Mode => Off
   is
      use type RFLX.Types.Index;
      Trunc     : Integer;
      Length    : Integer;
   begin
      Gneiss.Syscall.Peek_Message (Socket, Message'Address, Message'Length, Fd, Length, Trunc);
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
