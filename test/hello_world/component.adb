
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   procedure Initialize_Log (Session : in out Gneiss.Log.Client_Session);

   package Log_Client is new Gneiss.Log.Client (Initialize_Log);

   Cap : Gneiss.Capability;
   Log : Gneiss.Log.Client_Session;

   procedure Construct (Capability : Gneiss.Capability)
   is
   begin
      Cap := Capability;
      Log_Client.Initialize (Log, Cap, "log_hello_world");
   end Construct;

   procedure Initialize_Log (Session : in out Gneiss.Log.Client_Session)
   is
   begin
      case Gneiss.Log.Status (Session) is
         when Gneiss.Initialized =>
            Main.Vacate (Cap, Main.Success);
            Log_Client.Info (Session, "Hello World!");
            Log_Client.Warning (Session, "Hello World!");
            Log_Client.Error (Session, "Hello World!");
         when others =>
            Main.Vacate (Cap, Main.Failure);
      end case;
   end Initialize_Log;

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
