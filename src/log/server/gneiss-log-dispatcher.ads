
with Gneiss.Log.Server;

generic
   pragma Warnings (Off, "* is not referenced");
   with package Server_Instance is new Gneiss.Log.Server (<>);
   with procedure Dispatch (Session : in out Dispatcher_Session;
                            Cap     :        Dispatcher_Capability;
                            Name    :        String;
                            Label   :        String);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Log.Dispatcher with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 0);

   procedure Register (Session : in out Dispatcher_Session) with
      Pre  => Initialized (Session),
      Post => Initialized (Session);

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean with
      Pre => Initialized (Session);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Idx      :        Session_Index := 0) with
      Pre  => Initialized (Session)
              and then Valid_Session_Request (Session, Cap)
              and then not Server_Instance.Ready (Server_S)
              and then not Initialized (Server_S),
      Post => Initialized (Session)
              and then Valid_Session_Request (Session, Cap);

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session) with
      Pre  => Initialized (Session)
              and then Valid_Session_Request (Session, Cap)
              and then Server_Instance.Ready (Server_S)
              and then Initialized (Server_S),
      Post => Initialized (Session)
              and then Server_Instance.Ready (Server_S)
              and then Initialized (Server_S);

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session) with
      Pre  => Initialized (Session),
      Post => Initialized (Session);

end Gneiss.Log.Dispatcher;
