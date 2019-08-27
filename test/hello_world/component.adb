
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   Log : Componolit.Gneiss.Log.Client_Session;

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability)
   is
      Ml : Integer;
   begin
      Main.Vacate (Cap, Main.Success);
      if not Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Initialize (Log, Cap, "log_hello_world");
      end if;
      if Componolit.Gneiss.Log.Initialized (Log) then
         Ml := Componolit.Gneiss.Log.Maximum_Message_Length (Log);
         Componolit.Gneiss.Log.Client.Info (Log, "Hello World!");
         pragma Assert (Ml = Componolit.Gneiss.Log.Maximum_Message_Length (Log));
         Componolit.Gneiss.Log.Client.Warning (Log, "Hello World!");
         Componolit.Gneiss.Log.Client.Error (Log, "Hello World!");
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Info (Log, "Destructing...");
         Componolit.Gneiss.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
