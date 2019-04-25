
with Cai.Configuration;
with Cai.Configuration.Client;
with Cai.Log;
with Cai.Log.Client;

package body Component with
   SPARK_Mode
is

   Cfg : Cai.Configuration.Client_Session;
   Log : Cai.Log.Client_Session;
   C : Cai.Types.Capability;

   procedure Parse (Data : String);

   package Config is new Cai.Configuration.Client (Character, Positive, String, Parse);

   procedure Construct (Cap : Cai.Types.Capability)
   is
   begin
      Config.Initialize (Cfg, Cap);
      C := Cap;
      Config.Load (Cfg);
   end Construct;

   procedure Parse (Data : String)
   is
   begin
      Cai.Log.Client.Initialize (Log, C, Data);
      Cai.Log.Client.Info (Log, "Log session configured with label: " & Data);
   end Parse;

end Component;
