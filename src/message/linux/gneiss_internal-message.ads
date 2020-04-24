
with Gneiss;

generic
   pragma Warnings (Off, "* is not referenced");
   type Message_Buffer is private;
   Null_Buffer : Message_Buffer;
   pragma Warnings (On, "* is not referenced");
package Gneiss_Internal.Message with
   SPARK_Mode
is

   type Client_Session is record
      Fd    : File_Descriptor             := -1;
      Efd   : Epoll_Fd                    := -1;
      Label : Session_Label;
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap : Event_Cap                   := Invalid_Event_Cap;
   end record;

   type Server_Session is record
      Fd    : File_Descriptor             := -1;
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap : Event_Cap                   := Invalid_Event_Cap;
   end record;

   type Dispatcher_Session is record
      Broker_Fd   : File_Descriptor             := -1;
      Accepted    : Boolean                     := False;
      Efd         : Epoll_Fd                    := -1;
      Dispatch_Fd : File_Descriptor             := -1;
      Index       : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap       : Event_Cap                   := Invalid_Event_Cap;
   end record;

   type Dispatcher_Capability is limited record
      Client_Fd : File_Descriptor := -1;
      Server_Fd : File_Descriptor := -1;
      Clean_Fd  : File_Descriptor := -1;
      Name      : Session_Label;
      Label     : Session_Label;
   end record;

end Gneiss_Internal.Message;
