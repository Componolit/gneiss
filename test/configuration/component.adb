
with Componolit.Interfaces.Configuration;
with Componolit.Interfaces.Configuration.Client;
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;

package body Component with
   SPARK_Mode
is

   procedure Parse (Data : String);

   package Config is new Componolit.Interfaces.Configuration.Client (Character, Positive, String, Parse);

   Cfg : Componolit.Interfaces.Configuration.Client_Session := Config.Create;
   Log : Componolit.Interfaces.Log.Client_Session := Componolit.Interfaces.Log.Client.Create;
   C : Componolit.Interfaces.Types.Capability;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      if not Config.Initialized (Cfg) then
         Config.Initialize (Cfg, Cap);
      end if;
      C := Cap;
      if Config.Initialized (Cfg) then
         Config.Load (Cfg);
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Parse (Data : String)
   is
   begin
      if not Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, C, Data);
         if Componolit.Interfaces.Log.Client.Initialized (Log) then
            Componolit.Interfaces.Log.Client.Info (Log, "Log session configured with label: " & Data);
         else
            Main.Vacate (C, Main.Failure);
         end if;
      else
         Componolit.Interfaces.Log.Client.Info (Log, "Configuration changed, exiting...");
         Main.Vacate (C, Main.Success);
      end if;
   end Parse;

   procedure Destruct
   is
   begin
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
      if Config.Initialized (Cfg) then
         Config.Finalize (Cfg);
      end if;
   end Destruct;

end Component;
