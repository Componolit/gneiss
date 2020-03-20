
with Gneiss;
with Gneiss_Epoll;
with Gneiss_Platform;

package Gneiss_Internal.Timer with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   type Client_Session is limited record
      Fd    : Integer                     := -1;
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap : Gneiss_Platform.Event_Cap;
      Epoll : Gneiss_Epoll.Epoll_Fd       := -1;
   end record;

end Gneiss_Internal.Timer;
