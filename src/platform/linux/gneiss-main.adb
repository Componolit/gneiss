
with Ada.Unchecked_Conversion;
with Basalt.Strings;
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
   procedure Register_Initializer (Kind    :     RFLX.Session.Kind_Type;
                                   Cap     :     Gneiss_Platform.Initializer_Cap;
                                   Succ    : out Boolean);
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
   procedure Handle_Request (Kind  : RFLX.Session.Kind_Type;
                             Name  : String;
                             Label : String);

   Running : constant Integer := -1;
   Success : constant Integer := 0;
   Failure : constant Integer := 1;

   Component_Status : Integer                      := Running;
   Epoll_Fd         : Gneiss_Epoll.Epoll_Fd        := -1;
   Services         : Service_Registry;
   Broker_Fd        : Integer                      := -1;
   Initializers     : Initializer_Service_Registry;

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
      Load_Message (Context, Read_Label, Label_Last, Read_Name, Name_Last);
      Kind := RFLX.Session.Packet.Get_Kind (Context);
      case RFLX.Session.Packet.Get_Action (Context) is
         when RFLX.Session.Request =>
            Componolit.Runtime.Debug.Log_Debug ("Request");
            Handle_Request (Kind,
                            Read_Name (Read_Name'First .. Name_Last),
                            Read_Label (Read_Label'First .. Label_Last));
         when RFLX.Session.Confirm =>
            Componolit.Runtime.Debug.Log_Debug ("Confirm");
            Handle_Answer (Kind, Fd, Read_Label (Read_Label'First .. Label_Last));
         when RFLX.Session.Reject =>
            Componolit.Runtime.Debug.Log_Debug ("Reject");
            Handle_Answer (Kind, Fd, Read_Label (Read_Label'First .. Label_Last));
      end case;
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

   Return_Message : RFLX_String (1 .. 255);

   procedure Handle_Request (Kind  : RFLX.Session.Kind_Type;
                             Name  : String;
                             Label : String)
   is
      use type RFLX.Session.Length_Type;
      Dispatcher : constant Gneiss_Platform.Dispatcher_Cap :=
         Services (Kind);
      Next       : RFLX.Session.Length_Type := Return_Message'First;
      N_Length   : RFLX.Session.Length_Type;
      Client_Fd  : Integer := -1;
   begin
      if Name'Length + Label'Length < 256 then
         for C of Name loop
            Return_Message (Next) := C;
            Next := Next + 1;
         end loop;
         N_Length := Next - 1;
         for C of Label loop
            Return_Message (Next) := C;
            Next := Next + 1;
         end loop;
      else
         Componolit.Runtime.Debug.Log_Error ("Name and label too long, aborting answer");
         return;
      end if;
      if Gneiss_Platform.Is_Valid (Dispatcher) then
         Componolit.Runtime.Debug.Log_Debug ("Request accept");
         Message_Dispatcher (Dispatcher, Name, Label, Client_Fd);
         if Client_Fd >= 0 then
            Proto.Send_Message (Broker_Fd,
                                Proto.Message'(Length      => Next - 1,
                                               Action      => RFLX.Session.Confirm,
                                               Kind        => Kind,
                                               Name_Length => N_Length,
                                               Payload     => Return_Message
                                                (Return_Message'First .. Next - 1)),
                                Client_Fd);
            Gneiss.Syscall.Close (Client_Fd);
            return;
         end if;
      end if;
      Componolit.Runtime.Debug.Log_Debug ("Request reject");
      Proto.Send_Message
         (Broker_Fd,
          Proto.Message'(Length      => Next - 1,
                         Action      => RFLX.Session.Reject,
                         Kind        => Kind,
                         Name_Length => N_Length,
                         Payload     => Return_Message
                            (Return_Message'First .. Next - 1)));
   end Handle_Request;

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
            Componolit.Runtime.Debug.Log_Debug ("Name: " & Character'Val (Payload (Index)));
            Name (I)  := Character'Val (Payload (Index));
            Index     := Index + 1;
            Last_Name := I;
         end loop;
         for I in Label'Range loop
            Componolit.Runtime.Debug.Log_Debug ("Label: " & Character'Val (Payload (Index)));
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

end Gneiss.Main;
