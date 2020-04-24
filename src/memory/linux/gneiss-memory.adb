
with System;
with Gneiss_Internal;

package body Gneiss.Memory with
   SPARK_Mode
is
   use type System.Address;

   function Initialized (Session : Client_Session) return Boolean is
      (Session.Index.Valid
       and then Gneiss_Internal.Valid (Session.Fd)
       and then Session.Map /= System.Null_Address);

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Index.Valid
       and then Gneiss_Internal.Valid (Session.Fd)
       and then Session.Map /= System.Null_Address
       and then Gneiss_Internal.Valid (Session.E_Cap)
       and then Gneiss_Internal.Valid (Session.Sigfd));

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Session.Index.Valid
       and then Gneiss_Internal.Valid (Session.Efd)
       and then Gneiss_Internal.Valid (Session.Broker_Fd));

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

   function Registered (Session : Dispatcher_Session) return Boolean is
      (Gneiss_Internal.Valid (Session.Dispatch_Fd));

end Gneiss.Memory;
