
with Gneiss_Internal;

package body Gneiss.Message with
   SPARK_Mode
is

   function Initialized (Session : Client_Session) return Boolean is
      (Gneiss_Internal.Valid (Session.Fd)
       and then Session.Index.Valid
       and then Gneiss_Internal.Valid (Session.Efd)
       and then Gneiss_Internal.Valid (Session.E_Cap)
       and then Message_Buffer'Size = 128 * 8);

   function Initialized (Session : Server_Session) return Boolean is
      (Gneiss_Internal.Valid (Session.Fd)
       and then Session.Index.Valid
       and then Gneiss_Internal.Valid (Session.E_Cap)
       and then Message_Buffer'Size = 128 * 8);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Gneiss_Internal.Valid (Session.Broker_Fd)
       and then Gneiss_Internal.Valid (Session.Efd)
       and then Session.Index.Valid);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

   function Registered (Session : Dispatcher_Session) return Boolean is
      (Gneiss_Internal.Valid (Session.Dispatch_Fd));

end Gneiss.Message;
