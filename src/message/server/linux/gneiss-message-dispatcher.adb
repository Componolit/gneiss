
with System;
with Gneiss_Epoll;
with Gneiss_Platform;
with Gneiss_Syscall;
with RFLX.Session;

package body Gneiss.Message.Dispatcher with
   SPARK_Mode
is

   function Server_Event_Address (Session : Server_Session) return System.Address;
   procedure Session_Event (Session : in out Server_Session);
   function Event_Cap is new Gneiss_Platform.Create_Event_Cap (Server_Session, Session_Event);

   procedure Session_Event (Session : in out Server_Session)
   is
      pragma Unreferenced (Session);
   begin
      Server_Instance.Event;
   end Session_Event;

   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      : in out Gneiss_Syscall.Fd_Array;
                             Num     :    out Natural);

   function Server_Event_Address (Session : Server_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Server_Event_Address;

   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      : in out Gneiss_Syscall.Fd_Array;
                             Num     :    out Natural)
   is
   begin
      Session.Client_Fd := -1;
      Session.Accepted  := False;
      if Fd'Length = 1 then
         Dispatch (Session, Dispatcher_Capability'(Clean_Fd => Fd (Fd'First), others => -1), "", "");
         Num := 0;
         return;
      end if;
      Dispatch (Session, Dispatcher_Capability'(Clean_Fd  => -1,
                                                Client_Fd => Fd (Fd'First),
                                                Server_Fd => Fd (Fd'First + 1)),
                Name, Label);
      Num := (if Session.Accepted then 1 else 0);
   end Dispatch_Event;

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1)
   is
   begin
      Session.Register_Service := Cap.Register_Service;
      Session.Epoll_Fd         := Cap.Epoll_Fd;
      Session.Index            := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   function Reg_Dispatcher_Cap is new Gneiss_Platform.Create_Dispatcher_Cap
      (Dispatcher_Session, Dispatch_Event);

   procedure Register (Session : in out Dispatcher_Session)
   is
      Ignore_Success : Boolean;
   begin
      Gneiss_Platform.Call (Session.Register_Service,
                            RFLX.Session.Message,
                            Reg_Dispatcher_Cap (Session),
                            Ignore_Success);
   end Register;

   procedure Finalize (Session : in out Dispatcher_Session)
   is
   begin
      null;
   end Finalize;

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean is
      (Cap.Client_Fd > -1 and then Cap.Server_Fd > -1);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Idx      :        Session_Index := 1)
   is
      pragma Unreferenced (Session);
   begin
      Server_S.Fd    := Cap.Server_Fd;
      Server_S.Index := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
      Server_S.E_Cap := Event_Cap (Server_S);
      Server_Instance.Initialize (Server_S);
      if not Server_Instance.Ready (Server_S) then
         Server_S.Index := Gneiss.Session_Index_Option'(Valid => False);
         Gneiss_Syscall.Close (Server_S.Fd);
      end if;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session)
   is
      Ignore_Success : Integer;
   begin
      Session.Client_Fd := Cap.Client_Fd;
      Gneiss_Epoll.Add (Session.Epoll_Fd, Server_S.Fd, Server_Event_Address (Server_S), Ignore_Success);
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
         Gneiss_Syscall.Close (Server_S.Fd);
         Server_Instance.Finalize (Server_S);
         Server_S.Index := Gneiss.Session_Index_Option'(Valid => False);
      end if;
   end Session_Cleanup;

end Gneiss.Message.Dispatcher;
