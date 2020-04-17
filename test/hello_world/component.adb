
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   package Lg is new Gneiss.Log;
   package Log_Client is new Lg.Client;

   Cap : Gneiss.Capability;
   Log : Lg.Client_Session;

   procedure Construct (Capability : Gneiss.Capability)
   is
   begin
      Cap := Capability;
      Log_Client.Initialize (Log, Cap, "log_hello_world");
      if Lg.Initialized (Log) then
         Main.Vacate (Cap, Main.Success);
         Log_Client.Info (Log, "Hello World!");
         Log_Client.Warning (Log, "Hello World!");
         Log_Client.Error (Log, "Hello World!");
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Lg.Initialized (Log) then
         Log_Client.Info (Log, "Destructing...");
      end if;
      Log_Client.Finalize (Log);
   end Destruct;

end Component;
