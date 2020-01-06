
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   package Log_Client is new Gneiss.Log.Client (Event);

   Cap : Gneiss.Capability;
   Log : Gneiss.Log.Client_Session;

   procedure Construct (Capability : Gneiss.Capability)
   is
   begin
      Cap := Capability;
      Log_Client.Initialize (Log, Cap, "log_hello_world");
   end Construct;

   procedure Event
   is
   begin
      case Gneiss.Log.Status (Log) is
         when Gneiss.Initialized =>
            Main.Vacate (Cap, Main.Success);
            Log_Client.Info (Log, "Hello World!");
            Log_Client.Warning (Log, "Hello World!");
            Log_Client.Error (Log, "Hello World!");
         when Gneiss.Pending =>
            Log_Client.Initialize (Log, Cap, "log_hello_world");
         when Gneiss.Uninitialized =>
            Main.Vacate (Cap, Main.Failure);
      end case;
   end Event;

   procedure Destruct
   is
      use type Gneiss.Session_Status;
   begin
      if Gneiss.Log.Status (Log) = Gneiss.Initialized then
         Log_Client.Info (Log, "Destructing...");
      end if;
      Log_Client.Finalize (Log);
   end Destruct;

end Component;
