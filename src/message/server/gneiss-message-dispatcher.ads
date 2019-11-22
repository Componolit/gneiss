
with Gneiss.Types.Capability;
with Gneiss.Message.Server;

generic
   with package Server_Instance is new Gneiss.Message.Server (<>);
   with procedure Dispatch (Session    : in out Dispatcher_Session;
                            Capability :        Dispatcher_Capability);
package Gneiss.Message.Dispatcher with
   SPARK_Mode
is

   procedure Initialize (Session    : in out Dispatcher_Session;
                         Capability :        Gneiss.Types.Capability);

   procedure Register (Session : in out Dispatcher_Session) with
      Pre  => State (Session) = Initialized,
      Post => State (Session) = Initialized;

   procedure Finalize (Session : in out Dispatcher_Session) with
      Post => State (Session) = Uninitialized;

   function Valid_Session_Request (Session    : Dispatcher_Session;
                                   Capability : Dispatcher_Capability) return Boolean with
      Pre => State (Session) = Initialized;

   procedure Session_Initialize (Session    : in out Dispatcher_Session;
                                 Capability :        Dispatcher_Capability;
                                 Server_S   : in out Server_Session) with
      Pre  => State (Session) = Initialized
              and then Valid_Session_Request (Session, Capability)
              and then not Server_Instance.Ready (Server_S)
              and then State (Server_S) = Uninitialized,
      Post => State (Session) = Initialized
              and then Valid_Session_Request (Session, Capability);

   procedure Session_Accept (Session    : in out Dispatcher_Session;
                             Capability :        Dispatcher_Capability;
                             Server_S   : in out Server_Session) with
      Pre  => State (Session) = Initialized
              and then Valid_Session_Request (Session, Capability)
              and then Server_Instance.Ready (Server_S)
              and then State (Server_S) = Initialized,
      Post => State (Session) = Initialized
              and then Server_Instance.Ready (Server_S)
              and then State (Server_S) = Initialized;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Server_S : in out Server_Session) with
      Pre  => State (Session) = Initialized,
      Post => State (Session) = Initialized;

end Gneiss.Message.Dispatcher;
