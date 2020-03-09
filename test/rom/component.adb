
with Gneiss.Rom;
with Gneiss.Rom.Client;
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   package Rom is new Gneiss.Rom (Character, Positive, String);
   procedure Read (Session : in out Rom.Client_Session;
                   Data    :        String);
   package Rom_Client is new Rom.Client (Read);

   C      : Gneiss.Capability;
   Log    : Gneiss.Log.Client_Session;
   Config : Rom.Client_Session;

   procedure Construct (Capability : Gneiss.Capability)
   is
   begin
      C := Capability;
      Gneiss.Log.Client.Initialize (Log, C, "rom");
      Rom_Client.Initialize (Config, C, "config");
      if Gneiss.Log.Initialized (Log) and then Rom.Initialized (Config) then
         Rom_Client.Update (Config);
      else
         Main.Vacate (C, Main.Failure);
      end if;
   end Construct;

   procedure Read (Session : in out Rom.Client_Session;
                   Data    :        String)
   is
      pragma Unreferenced (Session);
   begin
      if Gneiss.Log.Initialized (Log) then
         Gneiss.Log.Client.Info (Log, "Rom content: " & Data);
         Main.Vacate (C, Main.Success);
      else
         Main.Vacate (C, Main.Failure);
      end if;
   end Read;

   procedure Destruct
   is
   begin
      Gneiss.Log.Client.Finalize (Log);
      Rom_Client.Finalize (Config);
   end Destruct;

end Component;
