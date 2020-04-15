
with Gneiss_Platform;
with Gneiss_Epoll;

package body Gneiss.Log with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   function Initialized (Session : Client_Session) return Boolean is
      (Session.File_Descriptor > -1);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Session.Broker_Fd > -1
       and then Session.Epoll_Fd > -1
       and then Session.Index.Valid);

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Fd >= 0 and then Gneiss_Platform.Is_Valid (Session.E_Cap));

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Log;
