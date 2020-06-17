
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Stream;
with Gneiss.Stream.Client;
with Basalt.Strings;

package body Stream_Client.Component with
   SPARK_Mode
is

   package Gneiss_Log is new Gneiss.Log;
   package Log_Client is new Gneiss_Log.Client;

   package Stream is new Gneiss.Stream (Positive, Character, String);

   procedure Receive (Session : in out Stream.Client_Session;
                      Data    :        String;
                      Read    :    out Natural);

   package Stream_Client is new Stream.Client (Receive);

   Client     : Stream.Client_Session;
   Log        : Gneiss_Log.Client_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
      Sent : Natural;
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Capability, "log_stream");
      Stream_Client.Initialize (Client, Capability, "log");
      if Gneiss_Log.Initialized (Log) and Stream.Initialized (Client) then
         Stream_Client.Send (Client, "Hello World!", Sent);
         if Sent = 13 then
            Log_Client.Info (Log, "Stream sent: Hello World!");
         else
            Log_Client.Warning (Log, "Sent wrong number of bytes: "
                                     & Basalt.Strings.Image (Sent));
         end if;
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Receive (Session : in out Stream.Client_Session;
                      Data    :        String;
                      Read    :    out Natural)
   is
   begin
      Read := 0;
      if not Gneiss_Log.Initialized (Log) then
         Main.Vacate (Capability, Main.Failure);
         return;
      end if;
      Read := Data'Length;
      Log_Client.Info (Log, "Received "
                            & Basalt.Strings.Image (Read)
                            & " bytes: "
                            & Data);
   end Receive;

   procedure Destruct
   is
   begin
      Log_Client.Finalize (Log);
      Stream_Client.Finalize (Client);
   end Destruct;

end Stream_Client.Component;
