
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Memory;
with Gneiss.Memory.Client;

package body Component with
   SPARK_Mode
is

   package Memory is new Gneiss.Memory (Character, Positive, String);

   Log        : Gneiss.Log.Client_Session;
   Mem        : Memory.Client_Session;
   Capability : Gneiss.Capability;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String) with
      Pre  => Memory.Initialized (Session)
              and then Gneiss.Log.Initialized (Log),
      Post => Memory.Initialized (Session)
              and then Gneiss.Log.Initialized (Log);

   package Memory_Client is new Memory.Client (Modify);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Gneiss.Log.Client.Initialize (Log, Capability, "log_memory");
      Memory_Client.Initialize (Mem, Capability, "shared", 4096);
      if Gneiss.Log.Initialized (Log) and Memory.Initialized (Mem) then
         Memory_Client.Modify (Mem);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String)
   is
      pragma Unreferenced (Session);
      Prefix : constant String := "Data: ";
      Last   : Integer         := Data'First - 1;
      Max    : Integer;
   begin
      if Data'Length < Integer'Last - Prefix'Length then
         Max := Data'Last;
      else
         Max := Data'Last - Prefix'Length;
      end if;
      for I in Data'First .. Max loop
         exit when Data (I) = ASCII.NUL;
         Last := I;
         pragma Loop_Invariant (Last in Data'First .. Max);
      end loop;
      Gneiss.Log.Client.Info (Log, Prefix & Data (Data'First .. Last));
      Main.Vacate (Capability, Main.Success);
   end Modify;

   procedure Destruct
   is
   begin
      Memory_Client.Finalize (Mem);
      Gneiss.Log.Client.Finalize (Log);
   end Destruct;

end Component;
