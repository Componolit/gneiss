
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Packet;
with Gneiss.Packet.Client;

package body Packet_Client.Component with
   SPARK_Mode
is

   package Gneiss_Log is new Gneiss.Log;
   package Log_Client is new Gneiss_Log.Client;

   procedure Event;

   package Packet is new Gneiss.Packet (Positive, Character, String);

   package Packet_Client is new Packet.Client (Event);

   Client     : Packet.Client_Session;
   Log        : Gneiss_Log.Client_Session;
   Capability : Gneiss.Capability;
   Buffer     : String (1 .. 128);

   procedure Construct (Cap : Gneiss.Capability)
   is
      Success : Boolean;
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Capability, "log_packet");
      Packet_Client.Initialize (Client, Capability, "log");
      if Gneiss_Log.Initialized (Log) and Packet.Initialized (Client) then
         Packet_Client.Send (Client, "Hello World!", Success);
         if Success then
            Log_Client.Info (Log, "Packet sent: Hello World!");
         else
            Log_Client.Warning (Log, "Failed to send packet");
         end if;
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
      Length : Natural;
   begin
      if
         not Gneiss_Log.Initialized (Log)
         or else not Packet.Initialized (Client)
      then
         return;
      end if;
      Packet_Client.Receive (Client, Buffer, Length);
      if Length > Buffer'Length then
         Log_Client.Warning (Log, "Packet too long, truncated");
         Length := Buffer'Length;
      end if;
      Log_Client.Info (Log, "Packet received: " & Buffer (Buffer'First .. Buffer'First + Length - 1));
      Main.Vacate (Capability, Main.Success);
   end Event;

   procedure Destruct
   is
   begin
      Log_Client.Finalize (Log);
      Packet_Client.Finalize (Client);
   end Destruct;

end Packet_Client.Component;
