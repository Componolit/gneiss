
with Gneiss.Rom;
with Gneiss.Rom.Client;
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   package Rom is new Gneiss.Rom (Character, Positive, String);

   C      : Gneiss.Capability;
   Log    : Gneiss.Log.Client_Session;
   Config : Rom.Client_Session;

   procedure Read (Session : in out Rom.Client_Session;
                   Data    :        String;
                   Ctx     : in out Gneiss.Log.Client_Session) with
      Pre  => Gneiss.Log.Initialized (Ctx),
      Post => Gneiss.Log.Initialized (Ctx);

   package Rom_Client is new Rom.Client (Gneiss.Log.Client_Session, Read);
   procedure Update is new Rom_Client.Update (Gneiss.Log.Initialized);

   procedure Construct (Capability : Gneiss.Capability)
   is
   begin
      C := Capability;
      Gneiss.Log.Client.Initialize (Log, C, "rom");
      Rom_Client.Initialize (Config, C, "config");
      if Gneiss.Log.Initialized (Log) and then Rom.Initialized (Config) then
         Update (Config, Log);
         Main.Vacate (C, Main.Success);
      else
         Main.Vacate (C, Main.Failure);
      end if;
   end Construct;

   procedure Read (Session : in out Rom.Client_Session;
                   Data    :        String;
                   Ctx     : in out Gneiss.Log.Client_Session)
   is
      pragma Unreferenced (Session);
      Prefix : constant String := "Rom content: ";
      Last   : Integer;
   begin
      if Data'Length < Positive'Last - Prefix'Length then
         Last := Data'Last;
      else
         Last := Data'Last - Prefix'Length;
      end if;
      Gneiss.Log.Client.Info (Ctx, Prefix & Data (Data'First .. Last));
   end Read;

   procedure Destruct
   is
   begin
      Gneiss.Log.Client.Finalize (Log);
      Rom_Client.Finalize (Config);
   end Destruct;

end Component;
