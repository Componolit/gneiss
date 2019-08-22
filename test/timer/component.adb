
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;
with Componolit.Gneiss.Timer;
with Componolit.Gneiss.Timer.Client;
with Componolit.Gneiss.Strings;

package body Component with
   SPARK_Mode
is

   procedure Event;

   package Timer_Client is new Componolit.Gneiss.Timer.Client (Event);

   Log        : Componolit.Gneiss.Log.Client_Session;
   Timer      : Componolit.Gneiss.Timer.Client_Session;
   Capability : Componolit.Gneiss.Types.Capability;

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability)
   is
   begin
      Capability := Cap;
      if not Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Initialize (Log, Cap, "Timer");
      end if;
      if not Componolit.Gneiss.Timer.Initialized (Timer) then
         Timer_Client.Initialize (Timer, Cap);
      end if;
      if
         Componolit.Gneiss.Log.Initialized (Log)
         and Componolit.Gneiss.Timer.Initialized (Timer)
      then
         Timer_Client.Set_Timeout (Timer, 60.0);
         Timer_Client.Set_Timeout (Timer, 1.5);
         Componolit.Gneiss.Log.Client.Info
            (Log, "Time: " & Componolit.Gneiss.Strings.Image (Duration (Timer_Client.Clock (Timer))));
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
   begin
      if
         Componolit.Gneiss.Log.Initialized (Log)
         and Componolit.Gneiss.Timer.Initialized (Timer)
      then
         Componolit.Gneiss.Log.Client.Info
            (Log, "Time: " & Componolit.Gneiss.Strings.Image (Duration (Timer_Client.Clock (Timer))));
         Main.Vacate (Capability, Main.Success);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Event;

   procedure Destruct
   is
   begin
      if Componolit.Gneiss.Timer.Initialized (Timer) then
         Timer_Client.Finalize (Timer);
      end if;
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
