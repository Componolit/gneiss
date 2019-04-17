
with Cai.Log;
with Cai.Log.Client;
with Cai.Timer;
with Cai.Timer.Client;

package body Component with
   SPARK_Mode
is

   procedure Construct (Cap : Cai.Types.Capability)
   is
      Log : Cai.Log.Client_Session := Cai.Log.Client.Create;
      Timer : Cai.Timer.Client_Session := Cai.Timer.Client.Create;
   begin
      Cai.Log.Client.Initialize (Log, Cap, "Timer");
      Cai.Timer.Client.Initialize (Timer, Cap);
      if Cai.Log.Client.Initialized (Log) and Cai.Timer.Client.Initialized (Timer) then
         Cai.Log.Client.Info (Log, "Time: " & Cai.Log.Image (Duration (Cai.Timer.Client.Clock (Timer))));
      end if;
   end Construct;

end Component;
