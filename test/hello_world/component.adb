
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   Cap : Gneiss.Capability;
   Log : Gneiss.Log.Client_Session;

   procedure Construct (Capability : Gneiss.Capability)
   is
   begin
      Cap := Capability;
      Gneiss.Log.Client.Initialize (Log, Cap, "log_hello_world");
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
      end if;
      Gneiss.Log.Client.Finalize (Log);
   end Destruct;

end Component;
