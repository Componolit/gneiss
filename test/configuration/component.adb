
with Cai.Configuration;
with Cai.Configuration.Client;
with Cai.Log;
with Cai.Log.Client;

package body Component with
   SPARK_Mode
is

   procedure Parse (Data : String);

   package Config is new Cai.Configuration.Client (Character, Positive, String, Parse);

   Cfg : Cai.Configuration.Client_Session := Config.Create;
   Log : Cai.Log.Client_Session := Cai.Log.Client.Create;
   C : Cai.Types.Capability;

   procedure Construct (Cap : Cai.Types.Capability)
   is
   begin
      Config.Initialize (Cfg, Cap);
      C := Cap;
      if Config.Initialized (Cfg) then
         Config.Load (Cfg);
      else
         Config_Component.Vacate (Cap, Config_Component.Failure);
      end if;
   end Construct;

   procedure Parse (Data : String)
   is
   begin
      if not Cai.Log.Client.Initialized (Log) then
         Cai.Log.Client.Initialize (Log, C, Data);
         if Cai.Log.Client.Initialized (Log) then
            Cai.Log.Client.Info (Log, "Log session configured with label: " & Data);
         else
            Config_Component.Vacate (C, Config_Component.Failure);
         end if;
      else
         Cai.Log.Client.Info (Log, "Configuration changed, exiting...");
         Config_Component.Vacate (C, Config_Component.Success);
      end if;
   end Parse;

   procedure Destruct
   is
   begin
      if Cai.Log.Client.Initialized (Log) then
         Cai.Log.Client.Finalize (Log);
      end if;
      if Config.Initialized (Cfg) then
         Config.Finalize (Cfg);
      end if;
   end Destruct;

end Component;
