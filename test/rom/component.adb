
with Gneiss.Rom;
with Gneiss.Rom.Client;
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   procedure Parse (Data : String);

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

   procedure Parse (Data : String)
   is
      Last : Positive := Data'Last;
   begin
      if not Gneiss.Log.Initialized (Log) and then Data'Length > 1 then
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
         Gneiss.Log.Client.Initialize (Log, C, Data (Data'First .. Last));
         if Gneiss.Log.Initialized (Log) then
            Gneiss.Log.Client.Info (Log, "Log session configured with label: "
                                                        & Data (Data'First .. Last));
         else
            Main.Vacate (C, Main.Failure);
         end if;
      else
         Gneiss.Log.Client.Info (Log, "Rom changed, exiting...");
         Main.Vacate (C, Main.Success);
      end if;
   end Parse;

   procedure Destruct
   is
   begin
      if Gneiss.Log.Initialized (Log) then
         Gneiss.Log.Client.Finalize (Log);
      end if;
      if Gneiss.Rom.Initialized (Cfg) then
         Config.Finalize (Cfg);
      end if;
   end Destruct;

end Component;
