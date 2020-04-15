
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Memory;
with Gneiss.Memory.Client;

package body Component with
   SPARK_Mode
is

   package Memory is new Gneiss.Memory (Character, Positive, String);

   Log     : Gneiss.Log.Client_Session;
   Mem     : Memory.Client_Session;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String;
                     Ctx     : in out Gneiss.Log.Client_Session) with
      Pre  => Memory.Initialized (Session)
              and then Gneiss.Log.Initialized (Ctx),
      Post => Memory.Initialized (Session)
              and then Gneiss.Log.Initialized (Ctx),
      Global => null;

   package Memory_Client is new Memory.Client (Gneiss.Log.Client_Session, Modify);

   procedure Modify is new Memory_Client.Modify (Gneiss.Log.Initialized);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Gneiss.Log.Client.Initialize (Log, Cap, "log_memory");
      Memory_Client.Initialize (Mem, Cap, "shared", 4096);
      if Gneiss.Log.Initialized (Log) and Memory.Initialized (Mem) then
         Modify (Mem, Log);
         Main.Vacate (Cap, Main.Success);
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String;
                     Ctx     : in out Gneiss.Log.Client_Session)
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
      Gneiss.Log.Client.Info (Ctx, Prefix & Data (Data'First .. Last));
   end Modify;

   procedure Destruct
   is
   begin
      Memory_Client.Finalize (Mem);
      Gneiss.Log.Client.Finalize (Log);
   end Destruct;

end Component;
