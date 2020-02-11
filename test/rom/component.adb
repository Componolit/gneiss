
with Gneiss.Rom;
with Gneiss.Rom.Client;
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is
   use type Gneiss.Session_Status;

   procedure Initialize_Log (Session : in out Gneiss.Log.Client_Session);

   package Log_Client is new Gneiss.Log.Client (Initialize_Log);
   package Rom is new Gneiss.Rom (Character, Positive, String);
   procedure Initialize_Rom (Session : in out Rom.Client_Session);
   procedure Read (Session : in out Rom.Client_Session;
                   Data    :        String);
   package Rom_Client is new Rom.Client (Initialize_Rom, Read);

   C      : Gneiss.Capability;
   Log    : Gneiss.Log.Client_Session;
   Config : Rom.Client_Session;

   procedure Construct (Capability : Gneiss.Capability)
   is
   begin
      C := Capability;
      Log_Client.Initialize (Log, C, "rom");
   end Construct;

   procedure Initialize_Log (Session : in out Gneiss.Log.Client_Session)
   is
   begin
      case Gneiss.Log.Status (Session) is
         when Gneiss.Initialized =>
            Rom_Client.Initialize (Config, C, "config");
         when others =>
            Main.Vacate (C, Main.Failure);
      end case;
   end Initialize_Log;

   procedure Initialize_Rom (Session : in out Rom.Client_Session)
   is
   begin
      case Rom.Status (Session) is
         when Gneiss.Initialized =>
            Rom_Client.Update (Session);
         when others =>
            Main.Vacate (C, Main.Failure);
      end case;
   end Initialize_Rom;

   procedure Read (Session : in out Rom.Client_Session;
                   Data    :        String)
   is
      pragma Unreferenced (Session);
   begin
      if Gneiss.Log.Status (Log) = Gneiss.Initialized then
         Log_Client.Info (Log, "Rom content: " & Data);
         Main.Vacate (C, Main.Success);
      else
         Main.Vacate (C, Main.Failure);
      end if;
   end Read;

   procedure Destruct
   is
   begin
      Log_Client.Finalize (Log);
      Rom_Client.Finalize (Config);
   end Destruct;

end Component;
