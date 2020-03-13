
with Gneiss_Platform;
with Gneiss_Epoll;

package body Gneiss.Message with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   function Initialized (Session : Client_Session) return Boolean is
      (Session.File_Descriptor >= 0
       and then Session.Index.Valid
       and then Session.Epoll_Fd >= 0
       and then Gneiss_Platform.Is_Valid (Session.Event_Cap));

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Fd >= 0
       and then Session.Index.Valid
       and then Session.Epoll_Fd >= 0
       and then Gneiss_Platform.Is_Valid (Session.E_Cap));

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Session.Broker_Fd >= 0
       and then Session.Epoll_Fd >= 0
       and then Session.Index.Valid
       and then Gneiss_Platform.Is_Valid (Session.E_Cap));

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Message;
