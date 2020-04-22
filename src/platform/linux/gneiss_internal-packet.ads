
with Gneiss_Protocol.Session;
with Gneiss_Protocol.Types;
with Gneiss_Internal.Linux;

private package Gneiss_Internal.Packet with
   SPARK_Mode,
   Abstract_State => (Packet_State with Part_Of => Gneiss_Internal.Platform_State)
is

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
   procedure Get (Data : Gneiss_Protocol.Types.Bytes) with
      Global => null;

   generic
      Field : String;
   procedure Set (Data : out Gneiss_Protocol.Types.Bytes) with
      Global => null;

   procedure Send (Fd     : File_Descriptor;
                   Buf    : Gneiss_Protocol.Types.Bytes;
                   Length : Integer;
                   Fds    : Fd_Array) with
      Pre    => Valid (Fd),
      Global => (In_Out => Linux.Linux_State);

   procedure Recv (Fd     :     File_Descriptor;
                   Buf    : out Gneiss_Protocol.Types.Bytes;
                   Fds    : out Fd_Array;
                   Block  :     Boolean) with
      Pre    => Valid (Fd),
      Global => (In_Out => Linux.Linux_State);

end Gneiss_Internal.Packet;
