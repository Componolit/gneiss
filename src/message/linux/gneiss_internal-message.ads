
with System;
with Gneiss;
with Gneiss_Epoll;
with Gneiss_Platform;

package Gneiss_Internal.Message with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;

   type Client_Session is record
      File_Descriptor : Integer               := -1;
      Epoll_Fd        : Gneiss_Epoll.Epoll_Fd := -1;
      Label           : Session_Label;
      Pending         : Boolean               := False;
      Index           : Gneiss.Session_Index  := 0;
      Event_Cap       : Gneiss_Platform.Event_Cap;
   end record;

   type Server_Session is record
      Fd    : Integer              := -1;
      Index : Gneiss.Session_Index := 0;
      E_Cap : Gneiss_Platform.Event_Cap;
   end record;

   type Dispatcher_Session is record
      Register_Service : Gneiss_Platform.Register_Service_Cap;
      Client_Fd        : Integer               := -1;
      Accepted         : Boolean               := False;
      Epoll_Fd         : Gneiss_Epoll.Epoll_Fd := -1;
      Index            : Gneiss.Session_Index  := 0;
   end record;

   type Dispatcher_Capability is limited record
      Clean_Fd : Integer := -1;
   end record;

   procedure Write (Fd   : Integer;
                    Msg  : System.Address;
                    Size : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_write";

   procedure Read (Fd   : Integer;
                   Msg  : System.Address;
                   Size : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_read";

   function Peek (Fd   : Integer) return Integer with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_peek";

end Gneiss_Internal.Message;
