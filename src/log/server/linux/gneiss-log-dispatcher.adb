
with RFLX.Session;
with System;
with Gneiss_Epoll;
with Gneiss_Platform;
with Gneiss_Syscall;
with Gneiss_Internal.Log;
with Gneiss_Internal.Message_Syscall;
with Gneiss.Platform_Client;

package body Gneiss.Log.Dispatcher with
   SPARK_Mode
is

   function Event_Cap_Address (Session : Server_Session) return System.Address;
   function Dispatch_Cap_Address (Session : Dispatcher_Session) return System.Address;

   procedure Session_Event (Session  : in out Server_Session;
                            Epoll_Ev :        Gneiss_Epoll.Event_Type);

   procedure Dispatch_Event (Session  : in out Dispatcher_Session;
                             Epoll_Ev :        Gneiss_Epoll.Event_Type);

   function Event_Cap is new Gneiss_Platform.Create_Event_Cap (Server_Session, Session_Event);
   function Dispatch_Cap is new Gneiss_Platform.Create_Event_Cap (Dispatcher_Session, Dispatch_Event);

   procedure Read_Buffer (Session : in out Server_Session) with
      Pre =>  Initialized (Session)
              and then Gneiss_Internal.Message_Syscall.Peek (Session.Fd)
                       >= Gneiss_Internal.Log.Message_Buffer'Length,
      Post => Initialized (Session)
              and then Session.Cursor = Session.Buffer'Last;

   function Event_Cap_Address (Session : Server_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Event_Cap_Address;

   function Dispatch_Cap_Address (Session : Dispatcher_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Dispatch_Cap_Address;

   procedure Dispatch_Event (Session  : in out Dispatcher_Session;
                             Epoll_Ev :        Gneiss_Epoll.Event_Type)
   is
      Fds        : Gneiss_Syscall.Fd_Array (1 .. 2);
      Name       : Gneiss_Internal.Session_Label;
      Label      : Gneiss_Internal.Session_Label;
   begin
      case Epoll_Ev is
         when Gneiss_Epoll.Epoll_Ev =>
            Session.Accepted := False;
            Platform_Client.Dispatch (Session.Dispatch_Fd,
                                      RFLX.Session.Log,
                                      Name, Label, Fds);
            Dispatch (Session,
                      Dispatcher_Capability'(Client_Fd => Fds (1),
                                             Server_Fd => Fds (2),
                                             Name      => Name,
                                             Label     => Label),
                      Name.Value (Name.Value'First .. Name.Last),
                      Label.Value (Label.Value'First .. Label.Last));
            if not Session.Accepted then
               Platform_Client.Reject (Session.Dispatch_Fd,
                                       RFLX.Session.Log,
                                       Name.Value (Name.Value'First .. Name.Last),
                                       Label.Value (Label.Value'First .. Label.Last));
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
      Session.E_Cap     := Dispatch_Cap (Session);
      Session.Broker_Fd := Cap.Broker_Fd;
   end Initialize;

   procedure Register (Session : in out Dispatcher_Session)
   is
      Ignore_Success : Integer;
   begin
      Platform_Client.Register (Session.Broker_Fd, RFLX.Session.Log, Session.Dispatch_Fd);
      if Session.Dispatch_Fd > -1 then
         Gneiss_Epoll.Add (Session.Epoll_Fd, Session.Dispatch_Fd,
                           Dispatch_Cap_Address (Session),
                           Ignore_Success);
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
      Server_S.Fd    := Cap.Server_Fd;
      Server_S.Index := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
      Server_S.E_Cap := Event_Cap (Server_S);
      Server_S.Epoll_Fd := Session.Epoll_Fd;
      Server_Instance.Initialize (Server_S);
      if not Server_Instance.Ready (Server_S) then
         Gneiss_Syscall.Close (Server_S.Fd);
         Server_S.Index := Gneiss.Session_Index_Option'(Valid => False);
         Gneiss_Platform.Invalidate (Server_S.E_Cap);
      end if;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session)
   is
      Ignore_Success : Integer;
   begin
      Gneiss_Epoll.Add (Session.Epoll_Fd, Server_S.Fd, Event_Cap_Address (Server_S), Ignore_Success);
      Platform_Client.Confirm (Session.Dispatch_Fd,
                               RFLX.Session.Log,
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

   procedure Session_Event (Session  : in out Server_Session;
                            Epoll_Ev :        Gneiss_Epoll.Event_Type)
   is
      Ignore_Success : Integer;
   begin
      case Epoll_Ev is
         when Gneiss_Epoll.Epoll_Ev =>
            Read_Buffer (Session);
            for I in Session.Buffer'Range loop
               exit when Session.Buffer (I) = ASCII.NUL;
               Session.Cursor := I;
            end loop;
            if Session.Cursor > Session.Buffer'First then
               Server_Instance.Write (Session, Session.Buffer (Session.Buffer'First .. Session.Cursor));
               --  FIXME: Copy buffer to fix aliasing
            end if;
         when Gneiss_Epoll.Epoll_Er =>
            Gneiss_Epoll.Remove (Session.Epoll_Fd, Session.Fd, Ignore_Success);
            Gneiss_Syscall.Close (Session.Fd);
            Server_Instance.Finalize (Session);
            Session.Index := Gneiss.Session_Index_Option'(Valid => False);
            Gneiss_Platform.Invalidate (Session.E_Cap);
      end case;
   end Session_Event;

   procedure Read_Buffer (Session : in out Server_Session) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message_Syscall.Read (Session.Fd, Session.Buffer'Address, Session.Buffer'Length);
      Session.Cursor := Session.Buffer'First;
   end Read_Buffer;

end Gneiss.Log.Dispatcher;
