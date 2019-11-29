
package body Gneiss.Message.Dispatcher with
   SPARK_Mode
is

   procedure Initialize (Session    : in out Dispatcher_Session;
                         Capability :        Gneiss.Types.Capability)
   is
   begin
      null;
   end Initialize;

   procedure Register (Session : in out Dispatcher_Session)
   is
   begin
      null;
   end Register;

   procedure Finalize (Session : in out Dispatcher_Session)
   is
   begin
      null;
   end Finalize;

   function Valid_Session_Request (Session    : Dispatcher_Session;
                                   Capability : Dispatcher_Capability) return Boolean is (False);

   procedure Session_Initialize (Session    : in out Dispatcher_Session;
                                 Capability :        Dispatcher_Capability;
                                 Server_S   : in out Server_Session)
   is
   begin
      null;
   end Session_Initialize;

   procedure Session_Accept (Session    : in out Dispatcher_Session;
                             Capability :        Dispatcher_Capability;
                             Server_S   : in out Server_Session)
   is
   begin
      null;
   end Session_Accept;

   procedure Session_Cleanup (Session    : in out Dispatcher_Session;
                              Capability :        Dispatcher_Capability;
                              Server_S   : in out Server_Session)
   is
   begin
      null;
   end Session_Cleanup;

end Gneiss.Message.Dispatcher;
