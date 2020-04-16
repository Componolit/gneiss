
with Gneiss_Platform;
with Gneiss_Epoll;

package body Gneiss.Log with
   SPARK_Mode
is

   function Initialized (Session : Client_Session) return Boolean is
      (Session.File_Descriptor > -1);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Session.Broker_Fd > -1
       and then Gneiss_Epoll.Valid_Fd (Session.Epoll_Fd)
       and then Session.Index.Valid
       and then (if Session.Registered then Session.Dispatch_Fd > -1));

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Fd >= 0
       and then Gneiss_Platform.Is_Valid (Session.E_Cap)
       and then Session.Index.Valid);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Log;
