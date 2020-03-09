
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Timer;
with Gneiss.Timer.Client;
with Basalt.Strings;

package body Component with
   SPARK_Mode
is
   procedure Event;

   package Timer_Client is new Gneiss.Timer.Client (Event);

   Log        : Gneiss.Log.Client_Session;
   Timer      : Gneiss.Timer.Client_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Gneiss.Log.Client.Initialize (Log, Capability, "log_timer");
      Timer_Client.Initialize (Timer, Capability);
      if Gneiss.Log.Initialized (Log) and then Gneiss.Timer.Initialized (Timer) then
         Timer_Client.Set_Timeout (Timer, 60.0);
         Timer_Client.Set_Timeout (Timer, 1.5);
               Gneiss.Log.Client.Info
                  (Log, "Time: " & Basalt.Strings.Image (Duration (Timer_Client.Clock (Timer))));
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
   begin
      if
         Gneiss.Log.Initialized (Log)
         and Gneiss.Timer.Initialized (Timer)
      then
         Gneiss.Log.Client.Info
            (Log, "Time: " & Basalt.Strings.Image (Duration (Timer_Client.Clock (Timer))));
         Main.Vacate (Capability, Main.Success);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Event;

   procedure Destruct
   is
   begin
      Timer_Client.Finalize (Timer);
      Gneiss.Log.Client.Finalize (Log);
   end Destruct;

end Component;
