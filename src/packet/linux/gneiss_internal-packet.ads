with Gneiss;

package Gneiss_Internal.Packet with
   SPARK_Mode
is

   type Client_Session is limited record
      Fd    : File_Descriptor             := -1;
      Efd   : Epoll_Fd                    := -1;
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap : Event_Cap                   := Invalid_Event_Cap;
   end record;

   type Server_Session is limited record
      Fd    : File_Descriptor             := -1;
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap : Event_Cap;
   end record;

   type Dispatcher_Session is limited record
      Broker_Fd   : File_Descriptor             := -1;
      Dispatch_Fd : File_Descriptor             := -1;
      Efd         : Epoll_Fd                    := -1;
      Index       : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap       : Event_Cap;
      Accepted    : Boolean                     := False;
   end record;

   type Dispatcher_Capability is limited record
      Client_Fd : File_Descriptor := -1;
      Server_Fd : File_Descriptor := -1;
      Clean_Fd  : File_Descriptor := -1;
      Name      : Session_Label;
      Label     : Session_Label;
   end record;

end Gneiss_Internal.Packet;
