
with Componolit.Interfaces.Rom;
with Componolit.Interfaces.Rom.Client;
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;

package body Component with
   SPARK_Mode
is

   procedure Parse (Data : String);

   package Config is new Componolit.Interfaces.Rom.Client (Character, Positive, String, Parse);

   Cfg : Componolit.Interfaces.Rom.Client_Session;
   Log : Componolit.Interfaces.Log.Client_Session;
   C : Componolit.Interfaces.Types.Capability;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      if not Componolit.Interfaces.Rom.Initialized (Cfg) then
         Config.Initialize (Cfg, Cap);
      end if;
      C := Cap;
      if Componolit.Interfaces.Rom.Initialized (Cfg) then
         Config.Load (Cfg);
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Parse (Data : String)
   is
      Last : Positive := Data'Last;
   begin
      if not Componolit.Interfaces.Log.Initialized (Log) and then Data'Length > 1 then
         for I in Data'Range loop
            if Data (I) = ASCII.LF then
               Last := I - 1;
               exit;
            end if;
         end loop;
         Componolit.Interfaces.Log.Client.Initialize (Log, C, Data (Data'First .. Last));
         if Componolit.Interfaces.Log.Initialized (Log) then
            Componolit.Interfaces.Log.Client.Info (Log, "Log session configured with label: "
                                                        & Data (Data'First .. Last));
         else
            Main.Vacate (C, Main.Failure);
         end if;
      else
         Componolit.Interfaces.Log.Client.Info (Log, "Rom changed, exiting...");
         Main.Vacate (C, Main.Success);
      end if;
   end Parse;

   procedure Destruct
   is
   begin
      if Componolit.Interfaces.Log.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
      if Componolit.Interfaces.Rom.Initialized (Cfg) then
         Config.Finalize (Cfg);
      end if;
   end Destruct;

end Component;
