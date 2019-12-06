
with Gneiss_Epoll;
with Gneiss_Platform;

package body Gneiss.Message with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   function Status (Session : Client_Session) return Session_Status is
      (if Session.Epoll_Fd >= 0 then Pending else
         (if Session.File_Descriptor < 0 then Uninitialized else Initialized));

   function Initialized (Session : Server_Session) return Boolean is
      (False);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Gneiss_Platform.Is_Valid (Session.Register_Service));

end Gneiss.Message;
