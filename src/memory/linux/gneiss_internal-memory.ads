
with Gneiss;
with System;
with Gneiss_Epoll;

package Gneiss_Internal.Memory with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   type Client_Session is limited record
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Fd    : Integer                     := -1;
      Sigfd : Integer                     := -1;
      Map   : System.Address              := System.Null_Address;
   end record;

   type Server_Session is limited record
      Index    : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Fd       : Integer                     := -1;
      Sigfd    : Integer                     := -1;
      Map      : System.Address              := System.Null_Address;
      E_Cap    : Gneiss_Platform.Event_Cap;
   end record;

   type Dispatcher_Session is limited record
      Broker_Fd   : Integer                     := -1;
      Index       : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Epoll_Fd    : Gneiss_Epoll.Epoll_Fd       := -1;
      Dispatch_Fd : Integer                     := -1;
      Accepted    : Boolean                     := False;
      Registered  : Boolean                     := False;
      E_Cap       : Gneiss_Platform.Event_Cap;
   end record;

   type Dispatcher_Capability is limited record
      Memfd     : Integer := -1;
      Client_Fd : Integer := -1;
      Server_Fd : Integer := -1;
      Clean_Fd  : Integer := -1;
      Name      : Session_Label;
      Label     : Session_Label;
   end record;

end Gneiss_Internal.Memory;
