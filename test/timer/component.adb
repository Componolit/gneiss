
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;
with Componolit.Interfaces.Timer;
with Componolit.Interfaces.Timer.Client;
with Componolit.Interfaces.Strings;

package body Component with
   SPARK_Mode
is

   procedure Event;

   package Timer_Client is new Componolit.Interfaces.Timer.Client (Event);

   Log        : Componolit.Interfaces.Log.Client_Session   := Componolit.Interfaces.Log.Client.Create;
   Timer      : Componolit.Interfaces.Timer.Client_Session := Timer_Client.Create;
   Capability : Componolit.Interfaces.Types.Capability;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      Capability := Cap;
      if not Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Timer");
      end if;
      if not Timer_Client.Initialized (Timer) then
         Timer_Client.Initialize (Timer, Cap);
      end if;
      if
         Componolit.Interfaces.Log.Client.Initialized (Log)
         and Timer_Client.Initialized (Timer)
      then
         Timer_Client.Set_Timeout (Timer, 60.0);
         Timer_Client.Set_Timeout (Timer, 1.5);
         Componolit.Interfaces.Log.Client.Info
            (Log, "Time: " & Componolit.Interfaces.Strings.Image (Duration (Timer_Client.Clock (Timer))));
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
   begin
      if
         Componolit.Interfaces.Log.Client.Initialized (Log)
         and Timer_Client.Initialized (Timer)
      then
         Componolit.Interfaces.Log.Client.Info
            (Log, "Time: " & Componolit.Interfaces.Strings.Image (Duration (Timer_Client.Clock (Timer))));
         Main.Vacate (Capability, Main.Success);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Event;

   procedure Destruct
   is
   begin
      if Timer_Client.Initialized (Timer) then
         Timer_Client.Finalize (Timer);
      end if;
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
