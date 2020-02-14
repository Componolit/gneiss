
with Gneiss;
with Gneiss_Epoll;
with Gneiss_Platform;

generic
   pragma Warnings (Off, "* is not referenced");
   type Message_Buffer is private;
   Null_Buffer : Message_Buffer;
   pragma Warnings (On, "* is not referenced");
package Gneiss_Internal.Message with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   type Client_Session is record
      File_Descriptor : Integer                     := -1;
      Epoll_Fd        : Gneiss_Epoll.Epoll_Fd       := -1;
      Label           : Session_Label;
      Pending         : Boolean                     := False;
      Index           : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Event_Cap       : Gneiss_Platform.Event_Cap;
   end record;

   type Server_Session is record
      Fd    : Integer                     := -1;
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap : Gneiss_Platform.Event_Cap;
   end record;

   type Dispatcher_Session is record
      Register_Service : Gneiss_Platform.Register_Service_Cap;
      Client_Fd        : Integer                     := -1;
      Accepted         : Boolean                     := False;
      Epoll_Fd         : Gneiss_Epoll.Epoll_Fd       := -1;
      Index            : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
   end record;

   type Dispatcher_Capability is limited record
      Clean_Fd  : Integer := -1;
      Client_Fd : Integer := -1;
      Server_Fd : Integer := -1;
   end record;

end Gneiss_Internal.Message;
