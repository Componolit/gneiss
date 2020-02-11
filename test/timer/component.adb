
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Timer;
with Gneiss.Timer.Client;
with Basalt.Strings;

package body Component with
   SPARK_Mode
is
   use type Gneiss.Session_Status;

   procedure Initialize_Timer (Session : in out Gneiss.Timer.Client_Session);
   procedure Initialize_Log (Session : in out Gneiss.Log.Client_Session);
   procedure Event;

   package Timer_Client is new Gneiss.Timer.Client (Initialize_Timer, Event);
   package Log_Client is new Gneiss.Log.Client (Initialize_Log);

   Log        : Gneiss.Log.Client_Session;
   Timer      : Gneiss.Timer.Client_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Cap, "log_timer");
   end Construct;

   procedure Initialize_Log (Session : in out Gneiss.Log.Client_Session)
   is
   begin
      if Gneiss.Log.Status (Session) = Gneiss.Initialized then
         Timer_Client.Initialize (Timer, Capability);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Initialize_Log;

   procedure Initialize_Timer (Session : in out Gneiss.Timer.Client_Session)
   is
   begin
      if
         Gneiss.Timer.Status (Session) = Gneiss.Initialized
         and then Gneiss.Log.Status (Log) = Gneiss.Initialized
      then
         Timer_Client.Set_Timeout (Session, 60.0);
         Timer_Client.Set_Timeout (Session, 1.5);
               Log_Client.Info
                  (Log, "Time: " & Basalt.Strings.Image (Duration (Timer_Client.Clock (Timer))));
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Initialize_Timer;

   procedure Event
   is
   begin
      if
         Gneiss.Log.Status (Log) = Gneiss.Initialized
         and Gneiss.Timer.Status (Timer) = Gneiss.Initialized
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
