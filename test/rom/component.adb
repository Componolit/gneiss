
with Gneiss.Rom;
with Gneiss.Rom.Client;
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is
   use type Gneiss.Session_Status;

   procedure Initialize;
   procedure Parse (Data : String);

   package Log_Client is new Gneiss.Log.Client (Initialize);
   package Config is new Gneiss.Rom.Client (Character, Positive, String, Parse);

   Cfg : Gneiss.Rom.Client_Session;
   Log : Gneiss.Log.Client_Session;
   C : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      if not Gneiss.Rom.Initialized (Cfg) then
         Config.Initialize (Cfg, Cap);
      end if;
      C := Cap;
      if Gneiss.Rom.Initialized (Cfg) then
         Config.Load (Cfg);
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Initialize
   is
   begin
      case Gneiss.Log.Status (Log) is
         when Gneiss.Initialized =>
            Log_Client.Info (Log, "Log session configured");
         when Gneiss.Pending =>
            Log_Client.Initialize (Log, C, "");
         when Gneiss.Uninitialized =>
            Main.Vacate (C, Main.Failure);
      end case;
   end Initialize;

   procedure Parse (Data : String)
   is
      Last : Positive := Data'Last;
   begin
      if Gneiss.Log.Status (Log) = Gneiss.Uninitialized and then Data'Length > 1 then
         for I in Data'Range loop
            if Data (I) = ASCII.LF then
               if I > Data'First then
                  Last := I - 1;
               else
                  Last := Data'First;
               end if;
               exit;
            end if;
         end loop;
         Log_Client.Initialize (Log, C, Data (Data'First .. Last));
      else
         Log_Client.Info (Log, "Rom changed, exiting...");
         Main.Vacate (C, Main.Success);
      end if;
   end Parse;

   procedure Destruct
   is
   begin
      Log_Client.Finalize (Log);
      Config.Finalize (Cfg);
   end Destruct;

end Component;
