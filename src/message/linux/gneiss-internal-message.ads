
with Gneiss.Internal.Types;
with Gneiss.Epoll;

package Gneiss.Internal.Message with
   SPARK_Mode
is
   use type Gneiss.Epoll.Epoll_Fd;

   type Client_Session is record
      File_Descriptor : Integer := -1;
      Epoll_Fd        : Gneiss.Epoll.Epoll_Fd := -1;
      Label           : Gneiss.Internal.Types.Session_Label;
   end record;

   type Server_Session is record
      null;
   end record;

   type Dispatcher_Session is record
      null;
   end record;

   type Dispatcher_Capability is null record;

end Gneiss.Internal.Message;
