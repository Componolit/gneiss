
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;

package body Component with
   SPARK_Mode
is

   Log : Componolit.Interfaces.Log.Client_Session := Componolit.Interfaces.Log.Client.Create;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
      Ml : Integer;
   begin
      Main.Vacate (Cap, Main.Success);
      if not Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Hello_World");
      end if;
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Ml := Componolit.Interfaces.Log.Client.Maximum_Message_Length (Log);
         Componolit.Interfaces.Log.Client.Info (Log, "Hello World!");
         pragma Assert (Ml = Componolit.Interfaces.Log.Client.Maximum_Message_Length (Log));
         Componolit.Interfaces.Log.Client.Warning (Log, "Hello World!");
         Componolit.Interfaces.Log.Client.Error (Log, "Hello World!");
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Info (Log, "Destructing...");
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
