
with Gneiss;
with Gneiss.Message;
with Gneiss_Epoll;
with Gneiss_Platform;

package Gneiss_Internal.Log with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   subtype Message_Buffer is String (1 .. 128);
   Null_Buffer : constant Message_Buffer := (others => ASCII.NUL);

   package Message_Log is new Gneiss.Message (Message_Buffer, Null_Buffer);

   type Client_Session is limited record
      File_Descriptor : Integer                     := -1;
      Label           : Session_Label;
      Pending         : Boolean                     := False;
      Index           : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Buffer          : Message_Buffer              := Null_Buffer;
      Cursor          : Natural                     := 0;
      Newline         : Boolean                     := True;
   end record;

   type Dispatcher_Session is record
      Register_Service : Gneiss_Platform.Register_Service_Cap;
      Client_Fd        : Integer                     := -1;
      Accepted         : Boolean                     := False;
      Epoll_Fd         : Gneiss_Epoll.Epoll_Fd       := -1;
      Index            : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
   end record;

   type Server_Session is limited record
      Fd     : Integer                     := -1;
      Index  : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Buffer : Message_Buffer              := Null_Buffer;
      Cursor : Positive                    := 1;
      E_Cap  : Gneiss_Platform.Event_Cap;
   end record;

   type Dispatcher_Capability is limited record
      Clean_Fd  : Integer := -1;
      Client_Fd : Integer := -1;
      Server_Fd : Integer := -1;
   end record;

end Gneiss_Internal.Log;
