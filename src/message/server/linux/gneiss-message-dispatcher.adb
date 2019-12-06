
with Gneiss_Platform;
with RFLX.Session;
with Componolit.Runtime.Debug;

package body Gneiss.Message.Dispatcher with
   SPARK_Mode
is
   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      :        Integer);

   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      :        Integer)
   is
      pragma Unreferenced (Session);
      pragma Unreferenced (Fd);
   begin
      Componolit.Runtime.Debug.Log_Debug ("Dispatch_Event " & Name & " " & Label);
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
                                   Cap     : Dispatcher_Capability) return Boolean is (False);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session)
   is
   begin
      null;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session)
   is
   begin
      null;
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session)
   is
   begin
      null;
   end Session_Cleanup;

end Gneiss.Message.Dispatcher;
