
with Gneiss_Platform;
with Gneiss.Syscall;
with Basalt.Strings;
with RFLX.Session;
with Componolit.Runtime.Debug;

package body Gneiss.Message.Dispatcher with
   SPARK_Mode
is
   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      : in out Integer);

   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      : in out Integer)
   is
   begin
      Componolit.Runtime.Debug.Log_Debug ("Dispatch_Event " & Name & " " & Label);
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
                         Cap     :        Capability)
   is
   begin
      Session.Register_Service := Cap.Register_Service;
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
      (Cap.Clean_Fd < 0);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session)
   is
      pragma Unreferenced (Cap);
   begin
      Gneiss.Syscall.Socketpair (Session.Client_Fd, Server_S.Fd);
      if Session.Client_Fd < 0 or else Server_S.Fd < 0 then
         return;
      end if;
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
      pragma Unreferenced (Server_S);
   begin
      Componolit.Runtime.Debug.Log_Debug ("Accept " & Basalt.Strings.Image (Session.Client_Fd));
      Session.Accepted := True;
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session)
   is
      pragma Unreferenced (Session);
   begin
      if Server_S.Fd = Cap.Clean_Fd then
         Gneiss.Syscall.Close (Server_S.Fd);
         Server_Instance.Finalize (Server_S);
      end if;
   end Session_Cleanup;

end Gneiss.Message.Dispatcher;
