
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Timer;
with Gneiss.Timer.Client;
with Basalt.Strings;

package body Component with
   SPARK_Mode
is
   use type Gneiss.Session_Status;

   procedure Event;
   procedure Initialize;

   package Timer_Client is new Gneiss.Timer.Client (Event);
   package Log_Client is new Gneiss.Log.Client (Initialize);

   Log        : Gneiss.Log.Client_Session;
   Timer      : Gneiss.Timer.Client_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Cap, "log_timer");
   end Construct;

   procedure Initialize
   is
   begin
      case Gneiss.Log.Status (Log) is
         when Gneiss.Initialized =>
            if Gneiss.Timer.Initialized (Timer) then
               return;
            end if;
            Timer_Client.Initialize (Timer, Capability);
            if Gneiss.Timer.Initialized (Timer) then
               Timer_Client.Set_Timeout (Timer, 60.0);
               Timer_Client.Set_Timeout (Timer, 1.5);
               Log_Client.Info
                  (Log, "Time: " & Basalt.Strings.Image (Duration (Timer_Client.Clock (Timer))));
            else
               Log_Client.Error (Log, "Failed to Initialize timer");
               Main.Vacate (Capability, Main.Failure);
            end if;
         when Gneiss.Pending =>
            Log_Client.Initialize (Log, Capability, "");
         when Gneiss.Uninitialized =>
            Main.Vacate (Capability, Main.Failure);
      end case;
   end Initialize;

   procedure Event
   is
   begin
      if
         Gneiss.Log.Status (Log) = Gneiss.Initialized
         and Gneiss.Timer.Initialized (Timer)
      then
         Log_Client.Info
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
      Log_Client.Finalize (Log);
   end Destruct;

end Component;
