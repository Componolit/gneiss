
package body Gneiss.Packet.Dispatcher with
   SPARK_Mode
is

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1)
   is
   begin
      null;
   end Initialize;

   procedure Register (Session : in out Dispatcher_Session)
   is
   begin
      null;
   end Register;

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean is
      (False);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Ctx      : in out Server_Instance.Context;
                                 Idx      :        Session_Index := 1)
   is
   begin
      null;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session;
                             Ctx      :        Server_Instance.Context)
   is
   begin
      null;
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session;
                              Ctx      : in out Server_Instance.Context)
   is
   begin
      null;
   end Session_Cleanup;

end Gneiss.Packet.Dispatcher;
