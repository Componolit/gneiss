
with Cai.Log;
with Cai.Log.Client;
with Cai.Timer;
with Cai.Timer.Client;

package body Component with
   SPARK_Mode
is

   Log : Cai.Log.Client_Session := Cai.Log.Client.Create;
   Timer : Cai.Timer.Client_Session := Cai.Timer.Client.Create;

   procedure Construct (Cap : Cai.Types.Capability)
   is
   begin
      Cai.Log.Client.Initialize (Log, Cap, "Timer");
      Cai.Timer.Client.Initialize (Timer, Cap);
      if Cai.Log.Client.Initialized (Log) and Cai.Timer.Client.Initialized (Timer) then
         Cai.Log.Client.Info (Log, "Time: " & Cai.Log.Image (Duration (Cai.Timer.Client.Clock (Timer))));
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Cai.Timer.Client.Initialized (Timer) then
         Cai.Timer.Client.Finalize (Timer);
      end if;
      if Cai.Log.Client.Initialized (Log) then
         Cai.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
