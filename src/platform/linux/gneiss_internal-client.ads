with Gneiss_Protocol.Session;

package Gneiss_Internal.Client with
   SPARK_Mode
is

   procedure Register (Broker_Fd :     File_Descriptor;
                       Kind      :     Gneiss_Protocol.Session.Kind_Type;
                       Fd        : out File_Descriptor) with
      Global => (In_Out => Gneiss_Internal.Platform_State),
      Pre    => Valid (Broker_Fd);

   procedure Initialize (Broker_Fd :        File_Descriptor;
                         Kind      :        Gneiss_Protocol.Session.Kind_Type;
                         Fds       : in out Fd_Array;
                         Label     :        String) with
      Pre    => Valid (Broker_Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Dispatch (Fd    :     File_Descriptor;
                       Kind  :     Gneiss_Protocol.Session.Kind_Type;
                       Name  : out Session_Label;
                       Label : out Session_Label;
                       Fds   : out Fd_Array) with
      Pre    => Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Confirm (Fd    : File_Descriptor;
                      Kind  : Gneiss_Protocol.Session.Kind_Type;
                      Name  : String;
                      Label : String;
                      Fds   : Fd_Array) with
      Pre    => Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Reject (Fd    : File_Descriptor;
                     Kind  : Gneiss_Protocol.Session.Kind_Type;
                     Name  : String;
                     Label : String) with
      Pre    => Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Send (Fd     : File_Descriptor;
                   Action : Gneiss_Protocol.Session.Action_Type;
                   Kind   : Gneiss_Protocol.Session.Kind_Type;
                   Name   : Session_Label;
                   Label  : Session_Label;
                   Fds    : Fd_Array) with
      Pre    => Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Receive (Fd    :     File_Descriptor;
                      Msg   : out Broker_Message;
                      Fds   : out Fd_Array;
                      Block :     Boolean) with
      Pre    => Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

end Gneiss_Internal.Client;
