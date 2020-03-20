
with Gneiss_Epoll;
with Gneiss_Platform;

package body Gneiss.Timer with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   function Initialized (Session : Client_Session) return Boolean is
      (Session.Fd > -1
       and then Session.Index.Valid
       and then Gneiss_Platform.Is_Valid (Session.E_Cap)
       and then Session.Epoll > -1);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Timer;
