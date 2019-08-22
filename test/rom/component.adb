
with Componolit.Gneiss.Rom;
with Componolit.Gneiss.Rom.Client;
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   procedure Parse (Data : String);

   package Config is new Componolit.Gneiss.Rom.Client (Character, Positive, String, Parse);

   Cfg : Componolit.Gneiss.Rom.Client_Session;
   Log : Componolit.Gneiss.Log.Client_Session;
   C : Componolit.Gneiss.Types.Capability;

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability)
   is
   begin
      if not Componolit.Gneiss.Rom.Initialized (Cfg) then
         Config.Initialize (Cfg, Cap);
      end if;
      C := Cap;
      if Componolit.Gneiss.Rom.Initialized (Cfg) then
         Config.Load (Cfg);
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Parse (Data : String)
   is
      Last : Positive := Data'Last;
   begin
      if not Componolit.Gneiss.Log.Initialized (Log) and then Data'Length > 1 then
         for I in Data'Range loop
            if Data (I) = ASCII.LF then
               Last := I - 1;
               exit;
            end if;
         end loop;
         Componolit.Gneiss.Log.Client.Initialize (Log, C, Data (Data'First .. Last));
         if Componolit.Gneiss.Log.Initialized (Log) then
            Componolit.Gneiss.Log.Client.Info (Log, "Log session configured with label: "
                                                        & Data (Data'First .. Last));
         else
            Main.Vacate (C, Main.Failure);
         end if;
      else
         Componolit.Gneiss.Log.Client.Info (Log, "Rom changed, exiting...");
         Main.Vacate (C, Main.Success);
      end if;
   end Parse;

   procedure Destruct
   is
   begin
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Finalize (Log);
      end if;
      if Componolit.Gneiss.Rom.Initialized (Cfg) then
         Config.Finalize (Cfg);
      end if;
   end Destruct;

end Component;
