
with Gneiss_Protocol.Session;
with Gneiss_Protocol.RFLX_Generic_Types;
with Gneiss_Internal.Linux;

private package Gneiss_Internal.Socket with
   SPARK_Mode,
   Abstract_State => (Packet_State with Part_Of => Gneiss_Internal.Platform_State)
is

   type Long_Natural is range 0 .. Natural'Last * 8;
   type String_Ptr is access String;
   package Types is new Gneiss_Protocol.RFLX_Generic_Types (Positive,
                                                            Character,
                                                            String,
                                                            String_Ptr,
                                                            Natural,
                                                            Long_Natural);

   procedure Send (Fd     : File_Descriptor;
                   Action : Gneiss_Protocol.Session.Action_Type;
                   Kind   : Gneiss_Protocol.Session.Kind_Type;
                   Name   : Session_Label;
                   Label  : Session_Label;
                   Fds    : Fd_Array) with
      Pre    => Valid (Fd),
      Global => (In_Out => (Packet_State, Linux.Linux_State));

   procedure Receive (Fd    :     File_Descriptor;
                      Msg   : out Broker_Message;
                      Fds   : out Fd_Array;
                      Block :     Boolean) with
      Pre    => Valid (Fd),
      Global => (In_Out => (Packet_State, Linux.Linux_State));

private

   generic
      Field : in out String;
      Last  : in out Natural;
   procedure Get (Data : String) with
      Global => null;

   generic
      Field : String;
   procedure Set (Data : out String) with
      Global => null;

   procedure Send (Fd     : File_Descriptor;
                   Buf    : String;
                   Length : Integer;
                   Fds    : Fd_Array) with
      Pre    => Valid (Fd),
      Global => (In_Out => Linux.Linux_State);

   procedure Recv (Fd     :     File_Descriptor;
                   Buf    : out String;
                   Length : out Natural;
                   Fds    : out Fd_Array;
                   Block  :     Boolean) with
      Pre    => Valid (Fd),
      Global => (In_Out => Linux.Linux_State);

end Gneiss_Internal.Socket;
