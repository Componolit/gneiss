
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   Log : Gneiss.Log.Client_Session;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      if not Gneiss.Log.Initialized (Log) then
         Gneiss.Log.Client.Initialize (Log, Cap, "log_hello_world");
      end if;
      if Gneiss.Log.Initialized (Log) then
         Main.Vacate (Cap, Main.Success);
         Gneiss.Log.Client.Info (Log, "Hello World!");
         Gneiss.Log.Client.Warning (Log, "Hello World!");
         Gneiss.Log.Client.Error (Log, "Hello World!");
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Gneiss.Log.Initialized (Log) then
         Gneiss.Log.Client.Info (Log, "Destructing...");
         Gneiss.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
