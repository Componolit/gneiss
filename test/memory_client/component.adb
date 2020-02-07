
with Gneiss.Memory;
with Gneiss.Memory.Client;

package body Component with
   SPARK_Mode
is

   procedure Event;

   package Memory is new Gneiss.Memory (Character, Positive, String);

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String);

   package Memory_Client is new Memory.Client (Event, Modify);

   Mem        : Memory.Client_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Memory_Client.Initialize (Mem, Cap, "shared", 4096);
   end Construct;

   procedure Event
   is
   begin
      case Memory.Status (Mem) is
         when Gneiss.Initialized =>
            Memory_Client.Modify (Mem);
         when Gneiss.Pending =>
            Memory_Client.Initialize (Mem, Capability, "", 4096);
         when Gneiss.Uninitialized =>
            Main.Vacate (Capability, Main.Failure);
      end case;
   end Event;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String)
   is
   begin
      null;
   end Modify;

   procedure Destruct
   is
   begin
      Memory_Client.Finalize (Mem);
   end Destruct;

end Component;
