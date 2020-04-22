
with Gneiss;
with System;

package Gneiss_Internal.Memory with
   SPARK_Mode
is

   type Client_Session is limited record
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Fd    : File_Descriptor             := -1;
      Sigfd : File_Descriptor             := -1;
      Map   : System.Address              := System.Null_Address;
   end record;

   type Server_Session is limited record
      Index    : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Fd       : File_Descriptor             := -1;
      Sigfd    : File_Descriptor             := -1;
      Map      : System.Address              := System.Null_Address;
      E_Cap    : Event_Cap                   := Invalid_Event_Cap;
   end record;

   type Dispatcher_Session is limited record
      Broker_Fd   : File_Descriptor             := -1;
      Index       : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Efd         : Epoll_Fd                    := -1;
      Dispatch_Fd : File_Descriptor             := -1;
      Accepted    : Boolean                     := False;
      Registered  : Boolean                     := False;
      E_Cap       : Event_Cap                   := Invalid_Event_Cap;
   end record;

   type Dispatcher_Capability is limited record
      Memfd     : File_Descriptor := -1;
      Client_Fd : File_Descriptor := -1;
      Server_Fd : File_Descriptor := -1;
      Clean_Fd  : File_Descriptor := -1;
      Name      : Session_Label;
      Label     : Session_Label;
   end record;

end Gneiss_Internal.Memory;
