
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;
with Componolit.Interfaces.Timer;
with Componolit.Interfaces.Timer.Client;

package body Component with
   SPARK_Mode
is

   Log : Componolit.Interfaces.Log.Client_Session := Componolit.Interfaces.Log.Client.Create;
   Timer : Componolit.Interfaces.Timer.Client_Session := Componolit.Interfaces.Timer.Client.Create;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      if not Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Timer");
      end if;
      if not Componolit.Interfaces.Timer.Client.Initialized (Timer) then
         Componolit.Interfaces.Timer.Client.Initialize (Timer, Cap);
      end if;
      if
         Componolit.Interfaces.Log.Client.Initialized (Log)
         and Componolit.Interfaces.Timer.Client.Initialized (Timer)
      then
         Main.Vacate (Cap, Main.Success);
         Componolit.Interfaces.Log.Client.Info
            (Log, "Time: " & Componolit.Interfaces.Log.Image
                                (Duration (Componolit.Interfaces.Timer.Client.Clock (Timer))));
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Componolit.Interfaces.Timer.Client.Initialized (Timer) then
         Componolit.Interfaces.Timer.Client.Finalize (Timer);
      end if;
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
