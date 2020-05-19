
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Packet;
with Gneiss.Packet.Client;

package body Component with
   SPARK_Mode
is

   package Gneiss_Log is new Gneiss.Log;
   package Log_Client is new Gneiss_Log.Client;

   procedure Event;

   subtype Desc_Index is Positive range 1 .. 10;

   package Packet is new Gneiss.Packet (Positive, Character, String, Desc_Index);

   type Descriptors is array (Desc_Index'Range) of Packet.Descriptor;

   procedure Update (Session : in out Packet.Client_Session;
                     Idx     :        Desc_Index;
                     Buf     :    out String;
                     Ctx     : in out Gneiss_Log.Client_Session);

   procedure Read (Session : in out Packet.Client_Session;
                   Idx     :        Desc_Index;
                   Buf     :        String;
                   Ctx     : in out Gneiss_Log.Client_Session);

   package Packet_Client is new Packet.Client (Gneiss_Log.Client_Session, Event, Update, Read);

   Client     : Packet.Client_Session;
   Log        : Gneiss_Log.Client_Session;
   Capability : Gneiss.Capability;
   Descs      : Descriptors;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Capability, "log_packet");
      Packet_Client.Initialize (Client, Capability, "log");
      if Gneiss_Log.Initialized (Log) and Packet.Initialized (Client) then
         Packet_Client.Allocate (Client, Descs (1), 12, 1);
         if Packet_Client.Allocated (Client, Descs (1)) then
            Packet_Client.Update (Client, Descs (1), Log);
            Packet_Client.Send (Client, Descs (1));
         else
            Main.Vacate (Capability, Main.Failure);
         end if;
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
   begin
      for I in Descs'Range loop
         if not Packet_Client.Allocated (Client, Descs (I)) then
            Packet_Client.Receive (Client, Descs (I), I);
            exit when not Packet_Client.Allocated (Client, Descs (I));
            Main.Vacate (Capability, Main.Success);
            Packet_Client.Read (Client, Descs (I), Log);
            Packet_Client.Free (Client, Descs (I));
         end if;
      end loop;
   end Event;

   procedure Update (Session : in out Packet.Client_Session;
                     Idx     :        Desc_Index;
                     Buf     :    out String;
                     Ctx     : in out Gneiss_Log.Client_Session)
   is
      pragma Unreferenced (Session);
      pragma Unreferenced (Idx);
      pragma Unreferenced (Ctx);
   begin
      Buf := (others => Character'Last);
      if Buf'Length >= 12 then
         Buf (Buf'First .. Buf'First + 11) := "Hello World!";
      end if;
      Log_Client.Info (Ctx, "Packet sent: " & Buf);
   end Update;

   procedure Read (Session : in out Packet.Client_Session;
                   Idx     :        Desc_Index;
                   Buf     :        String;
                   Ctx     : in out Gneiss_Log.Client_Session)
   is
      pragma Unreferenced (Session);
      pragma Unreferenced (Idx);
   begin
      Log_Client.Info (Ctx, "Packet received: " & Buf);
   end Read;

   procedure Destruct
   is
   begin
      Log_Client.Finalize (Log);
      Packet_Client.Finalize (Client);
   end Destruct;

end Component;
