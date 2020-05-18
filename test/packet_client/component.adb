
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
                     Ctx     : in out Descriptors);

   procedure Read (Session : in out Packet.Client_Session;
                   Idx     :        Desc_Index;
                   Buf     :        String;
                   Ctx     : in out Descriptors);

   package Packet_Client is new Packet.Client (Descriptors, Event, Update, Read);

   Client     : Packet.Client_Session;
   Log        : Gneiss_Log.Client_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Capability, "log_packet");
      Packet_Client.Initialize (Client, Capability, "log");
      if Gneiss_Log.Initialized (Log) and Packet.Initialized (Client) then
         null;
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
   begin
      null;
   end Event;

   procedure Update (Session : in out Packet.Client_Session;
                     Idx     :        Desc_Index;
                     Buf     :    out String;
                     Ctx     : in out Descriptors)
   is
   begin
      null;
   end Update;

   procedure Read (Session : in out Packet.Client_Session;
                   Idx     :        Desc_Index;
                   Buf     :        String;
                   Ctx     : in out Descriptors)
   is
   begin
      null;
   end Read;

   procedure Destruct
   is
   begin
      Log_Client.Finalize (Log);
      Packet_Client.Finalize (Client);
   end Destruct;

end Component;
