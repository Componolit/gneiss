with Gneiss_Internal.Packet_Session;

package body Gneiss.Packet.Server with
   SPARK_Mode
is

   procedure Send (Session : in out Server_Session;
                   Data    :        Buffer;
                   Success :    out Boolean;
                   Ctx     :        Context)
   is
      pragma Unreferenced (Ctx);
      Length : Natural := Data'Length;
   begin
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Send (Session.Fd, Data'Address, Length);
      Success := Length = Data'Length;
   end Send;

   procedure Receive (Session : in out Server_Session;
                      Data    :    out Buffer;
                      Length  :    out Natural;
                      Ctx     :        Context)
   is
      pragma Unreferenced (Ctx);
   begin
      Length := Data'Length;
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Receive (Session.Fd, Data'Address, Length);
   end Receive;

end Gneiss.Packet.Server;
