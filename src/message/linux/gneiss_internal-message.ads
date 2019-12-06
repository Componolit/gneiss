
with Gneiss_Epoll;

package Gneiss_Internal.Message with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   type Client_Session is record
      File_Descriptor : Integer := -1;
      Epoll_Fd        : Gneiss_Epoll.Epoll_Fd := -1;
      Label           : Session_Label;
   end record;

   type Server_Session is record
      null;
   end record;

   type Dispatcher_Session is record
      Register_Service : Gneiss_Platform.Register_Service_Cap;
   end record;

   type Dispatcher_Capability is null record;

end Gneiss_Internal.Message;
