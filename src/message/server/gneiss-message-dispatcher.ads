
with Gneiss.Message.Server;

generic
   pragma Warnings (Off, "* is not referenced");
   with package Server_Instance is new Gneiss.Message.Server (<>);
   with procedure Dispatch (Session : in out Dispatcher_Session;
                            Cap     :        Dispatcher_Capability);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Message.Dispatcher with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability);

   procedure Register (Session : in out Dispatcher_Session) with
      Pre  => Status (Session) = Initialized,
      Post => Status (Session) = Initialized;

   procedure Finalize (Session : in out Dispatcher_Session) with
      Post => Status (Session) = Uninitialized;

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean with
      Pre => Status (Session) = Initialized;

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session) with
      Pre  => Status (Session) = Initialized
              and then Valid_Session_Request (Session, Cap)
              and then not Server_Instance.Ready (Server_S)
              and then Status (Server_S) = Uninitialized,
      Post => Status (Session) = Initialized
              and then Valid_Session_Request (Session, Cap);

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session) with
      Pre  => Status (Session) = Initialized
              and then Valid_Session_Request (Session, Cap)
              and then Server_Instance.Ready (Server_S)
              and then Status (Server_S) = Initialized,
      Post => Status (Session) = Initialized
              and then Server_Instance.Ready (Server_S)
              and then Status (Server_S) = Initialized;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session) with
      Pre  => Status (Session) = Initialized,
      Post => Status (Session) = Initialized;

end Gneiss.Message.Dispatcher;
