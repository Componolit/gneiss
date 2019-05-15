
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
      if not Cai.Log.Client.Initialized (Log) then
         Cai.Log.Client.Initialize (Log, Cap, "Timer");
      end if;
      if not Cai.Timer.Client.Initialized (Timer) then
         Cai.Timer.Client.Initialize (Timer, Cap);
      end if;
      if Cai.Log.Client.Initialized (Log) and Cai.Timer.Client.Initialized (Timer) then
         Timer_Component.Vacate (Cap, Timer_Component.Success);
         Cai.Log.Client.Info (Log, "Time: " & Cai.Log.Image (Duration (Cai.Timer.Client.Clock (Timer))));
      else
         Timer_Component.Vacate (Cap, Timer_Component.Failure);
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
