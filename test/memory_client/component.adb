
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Memory;
with Gneiss.Memory.Client;

package body Component with
   SPARK_Mode
is

   package Memory is new Gneiss.Memory (Character, Positive, String);

   procedure Initialize_Log (Session : in out Gneiss.Log.Client_Session);
   procedure Initialize_Memory (Session : in out Memory.Client_Session);

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String);

   package Log_Client is new Gneiss.Log.Client (Initialize_Log);
   package Memory_Client is new Memory.Client (Initialize_Memory, Modify);

   Log        : Gneiss.Log.Client_Session;
   Mem        : Memory.Client_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Cap, "log_memory");
   end Construct;

   procedure Initialize_Log (Session : in out Gneiss.Log.Client_Session)
   is
      use type Gneiss.Session_Status;
   begin
      if Gneiss.Log.Status (Session) = Gneiss.Initialized then
         Memory_Client.Initialize (Mem, Capability, "shared", 4096);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Initialize_Log;

   procedure Initialize_Memory (Session : in out Memory.Client_Session)
   is
   begin
      case Memory.Status (Session) is
         when Gneiss.Initialized =>
            Memory_Client.Modify (Session);
         when others =>
            Main.Vacate (Capability, Main.Failure);
      end case;
   end Initialize_Memory;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String)
   is
      pragma Unreferenced (Session);
      Last : Positive := Data'First;
   begin
      for I in Data'Range loop
         exit when Data (I) = ASCII.NUL;
         Last := I;
      end loop;
      Log_Client.Info (Log, "Data: " & Data (Data'First .. Last));
      Main.Vacate (Capability, Main.Success);
   end Modify;

   procedure Destruct
   is
   begin
      Memory_Client.Finalize (Mem);
      Log_Client.Finalize (Log);
   end Destruct;

end Component;
