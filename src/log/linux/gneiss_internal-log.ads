
with Gneiss;
with Gneiss.Message;

package Gneiss_Internal.Log with
   SPARK_Mode
is

   subtype Message_Buffer is String (1 .. 128);
   Null_Buffer : constant Message_Buffer := (others => ASCII.NUL);

   package Message_Log is new Gneiss.Message (Message_Buffer, Null_Buffer);

   type Client_Session is limited record
      Fd      : File_Descriptor := -1;
      Label   : Session_Label;
      Buffer  : Message_Buffer  := Null_Buffer;
      Cursor  : Natural         := 0;
      Newline : Boolean         := True;
   end record;

   type Dispatcher_Session is record
      Broker_Fd   : File_Descriptor             := -1;
      E_Cap       : Event_Cap                   := Invalid_Event_Cap;
      Accepted    : Boolean                     := False;
      Efd         : Epoll_Fd                    := -1;
      Index       : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Dispatch_Fd : File_Descriptor             := -1;
      Registered  : Boolean                     := False;
   end record;

   type Server_Session is limited record
      Fd     : File_Descriptor             := -1;
      Index  : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Buffer : Message_Buffer              := Null_Buffer;
      Cursor : Positive                    := 1;
      E_Cap  : Event_Cap                   := Invalid_Event_Cap;
   end record;

   type Dispatcher_Capability is limited record
      Client_Fd : File_Descriptor := -1;
      Server_Fd : File_Descriptor := -1;
      Clean_Fd  : File_Descriptor := -1;
      Name      : Session_Label;
      Label     : Session_Label;
   end record;

end Gneiss_Internal.Log;
