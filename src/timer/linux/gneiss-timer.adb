
with Gneiss_Internal;

package body Gneiss.Timer with
   SPARK_Mode
is

   function Initialized (Session : Client_Session) return Boolean is
      (Gneiss_Internal.Valid (Session.Fd)
       and then Session.Index.Valid
       and then Gneiss_Internal.Valid (Session.E_Cap)
       and then Gneiss_Internal.Valid (Session.Epoll));

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Timer;
