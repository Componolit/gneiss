
with System;
with Gneiss_Epoll;
with Gneiss_Platform;

package body Gneiss.Memory with
   SPARK_Mode
is
   use type System.Address;
   use type Gneiss_Epoll.Epoll_Fd;

   function Initialized (Session : Client_Session) return Boolean is
      (Session.Index.Valid
       and then Session.Fd > -1
       and then Session.Map /= System.Null_Address);

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Index.Valid
       and then Session.Fd > -1
       and then Session.Map /= System.Null_Address
       and then Gneiss_Platform.Is_Valid (Session.E_Cap)
       and then Session.Sigfd > -1);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Session.Index.Valid
       and then Session.Epoll_Fd > -1
       and then Session.Broker_Fd > -1
       and then (if Session.Registered then Session.Dispatch_Fd > -1));

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Memory;
