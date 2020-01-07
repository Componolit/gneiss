
with RFLX.Session;
with System;
with Gneiss_Epoll;
with Gneiss_Platform;
with Gneiss.Syscall;

package body Gneiss.Log.Dispatcher with
   SPARK_Mode
is

   function Server_Event_Address return System.Address;

   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      : in out Integer);

   function Server_Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Server_Instance.Event'Address;
   end Server_Event_Address;

   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      : in out Integer)
   is
   begin
      Session.Client_Fd := -1;
      Session.Accepted  := False;
      if Fd >= 0 then
         Dispatch (Session, Dispatcher_Capability'(Clean_Fd => Fd), "", "");
         return;
      end if;
      Dispatch (Session, Dispatcher_Capability'(Clean_Fd => -1), Name, Label);
      Fd := (if Session.Accepted then Session.Client_Fd else -1);
   end Dispatch_Event;

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 0)
   is
   begin
      Session.Register_Service := Cap.Register_Service;
      Session.Epoll_Fd         := Cap.Epoll_Fd;
      Session.Index            := Idx;
   end Initialize;

   function Reg_Dispatcher_Cap is new Gneiss_Platform.Create_Dispatcher_Cap
      (Dispatcher_Session, Dispatch_Event);

   procedure Register (Session : in out Dispatcher_Session)
   is
      Ignore_Success : Boolean;
   begin
      Gneiss_Platform.Call (Session.Register_Service,
                            RFLX.Session.Log,
                            Reg_Dispatcher_Cap (Session),
                            Ignore_Success);
   end Register;

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean is
      (Cap.Clean_Fd < 0);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Idx      :        Session_Index := 0)
   is
      pragma Unreferenced (Cap);
   begin
      Gneiss.Syscall.Socketpair (Session.Client_Fd, Server_S.Fd);
      if Session.Client_Fd < 0 or else Server_S.Fd < 0 then
         return;
      end if;
      Server_S.Index := Idx;
      Server_Instance.Initialize (Server_S);
      if not Server_Instance.Ready (Server_S) then
         Gneiss.Syscall.Close (Server_S.Fd);
         Gneiss.Syscall.Close (Session.Client_Fd);
      end if;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session)
   is
      pragma Unreferenced (Cap);
      Ignore_Success : Integer;
   begin
      Gneiss_Epoll.Add (Session.Epoll_Fd, Server_S.Fd, Server_Event_Address, Ignore_Success);
      Session.Accepted := True;
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session)
   is
      Ignore_Success : Integer;
   begin
      if
         Cap.Clean_Fd >= 0
         and then Server_S.Fd = Cap.Clean_Fd
      then
         Gneiss_Epoll.Remove (Session.Epoll_Fd, Server_S.Fd, Ignore_Success);
         Gneiss.Syscall.Close (Server_S.Fd);
         Server_Instance.Finalize (Server_S);
      end if;
   end Session_Cleanup;

end Gneiss.Log.Dispatcher;
