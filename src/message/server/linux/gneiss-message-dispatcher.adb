
with System;
with Gneiss_Epoll;
with Gneiss_Platform;
with Gneiss.Platform_Client;
with Gneiss_Syscall;
with Gneiss_Internal.Message_Syscall;
with RFLX.Session;

package body Gneiss.Message.Dispatcher with
   SPARK_Mode
is

   function Server_Event_Address (Session : Server_Session) return System.Address;
   function Dispatch_Event_Address (Session : Dispatcher_Session) return System.Address;
   procedure Session_Event (Session  : in out Server_Session;
                            Epoll_Ev :        Gneiss_Epoll.Event_Type);
   procedure Dispatch_Event (Session  : in out Dispatcher_Session;
                             Epoll_Ev :        Gneiss_Epoll.Event_Type);
   function Event_Cap is new Gneiss_Platform.Create_Event_Cap (Server_Session, Session_Event);
   function Dispatch_Cap is new Gneiss_Platform.Create_Event_Cap (Dispatcher_Session, Dispatch_Event);

   function Available (Session : Server_Session) return Boolean is
      (Gneiss_Internal.Message_Syscall.Peek (Session.Fd) >= Message_Buffer'Size * 8);

   procedure Read (Session : in out Server_Session;
                   Data    :    out Message_Buffer);

   procedure Read (Session : in out Server_Session;
                   Data    :    out Message_Buffer) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message_Syscall.Read (Session.Fd, Data'Address, Data'Size * 8);
   end Read;

   procedure Session_Event (Session  : in out Server_Session;
                            Epoll_Ev :        Gneiss_Epoll.Event_Type)
   is
      use type Gneiss_Epoll.Epoll_Fd;
      Buffer         : Message_Buffer;
      Ignore_Success : Integer;
   begin
      case Epoll_Ev is
         when Gneiss_Epoll.Epoll_Ev =>
            if Available (Session) then
               Read (Session, Buffer);
               Server_Instance.Receive (Session, Buffer);
            end if;
         when Gneiss_Epoll.Epoll_Er =>
            Gneiss_Epoll.Remove (Session.Epoll_Fd, Session.Fd, Ignore_Success);
            Gneiss_Syscall.Close (Session.Fd);
            Server_Instance.Finalize (Session);
            Session.Index    := Gneiss.Session_Index_Option'(Valid => False);
            Session.Epoll_Fd := -1;
            Gneiss_Platform.Invalidate (Session.E_Cap);
      end case;
   end Session_Event;

   function Server_Event_Address (Session : Server_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Server_Event_Address;

   function Dispatch_Event_Address (Session : Dispatcher_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Dispatch_Event_Address;

   procedure Dispatch_Event (Session  : in out Dispatcher_Session;
                             Epoll_Ev :        Gneiss_Epoll.Event_Type)
   is
      Fds        : Gneiss_Syscall.Fd_Array (1 .. 2);
      Name       : String (1 .. 255);
      Label      : String (1 .. 255);
      Name_Last  : Natural;
      Label_Last : Natural;
   begin
      case Epoll_Ev is
         when Gneiss_Epoll.Epoll_Ev =>
            Session.Accepted := False;
            Platform_Client.Dispatch (Session.Dispatch_Fd, RFLX.Session.Message,
                                      Name, Name_Last,
                                      Label, Label_Last,
                                      Fds);
            Dispatch (Session,
                      Dispatcher_Capability'(Client_Fd => Fds (1),
                                             Server_Fd => Fds (2),
                                             Name      => Gneiss_Internal.Session_Label'(Value => Name,
                                                                                         Last  => Name_Last),
                                             Label     => Gneiss_Internal.Session_Label'(Value => Label,
                                                                                         Last  => Label_Last)),
                      Name (Name'First .. Name_Last),
                      Label (Label'First .. Label_Last));
            if not Session.Accepted then
               Platform_Client.Reject (Session.Dispatch_Fd,
                                       RFLX.Session.Message,
                                       Name (Name'First .. Name_Last),
                                       Label (Label'First .. Label_Last));
            end if;
         when Gneiss_Epoll.Epoll_Er =>
            null;
      end case;
   end Dispatch_Event;

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1)
   is
   begin
      Session.Epoll_Fd  := Cap.Epoll_Fd;
      Session.Index     := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
      Session.Broker_Fd := Cap.Broker_Fd;
      Session.E_Cap     := Dispatch_Cap (Session);
   end Initialize;

   procedure Register (Session : in out Dispatcher_Session)
   is
      Ignore_Success : Integer;
   begin
      Platform_Client.Register (Session.Broker_Fd, RFLX.Session.Message, Session.Dispatch_Fd);
      if Session.Dispatch_Fd > -1 then
         Gneiss_Epoll.Add (Session.Epoll_Fd, Session.Dispatch_Fd,
                           Dispatch_Event_Address (Session), Ignore_Success);
      end if;
   end Register;

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean is
      (Cap.Client_Fd > -1 and then Cap.Server_Fd > -1);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Idx      :        Session_Index := 1)
   is
   begin
      Server_S.Fd       := Cap.Server_Fd;
      Server_S.Index    := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
      Server_S.Epoll_Fd := Session.Epoll_Fd;
      Server_S.E_Cap    := Event_Cap (Server_S);
      Server_Instance.Initialize (Server_S);
      if not Server_Instance.Ready (Server_S) then
         Server_S.Index := Gneiss.Session_Index_Option'(Valid => False);
         Gneiss_Syscall.Close (Server_S.Fd);
         Gneiss_Platform.Invalidate (Server_S.E_Cap);
      end if;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session)
   is
      Ignore_Success : Integer;
   begin
      Gneiss_Epoll.Add (Session.Epoll_Fd, Server_S.Fd, Server_Event_Address (Server_S), Ignore_Success);
      Platform_Client.Confirm (Session.Dispatch_Fd,
                               RFLX.Session.Message,
                               Cap.Name.Value (Cap.Name.Value'First .. Cap.Name.Last),
                               Cap.Label.Value (Cap.Label.Value'First .. Cap.Label.Last),
                               (1 => Cap.Client_Fd));
      Session.Accepted := True;
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session)
   is
   begin
      null;
   end Session_Cleanup;

end Gneiss.Message.Dispatcher;
