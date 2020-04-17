
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Memory;
with Gneiss.Memory.Client;

package body Component with
   SPARK_Mode
is

   package Gneiss_Log is new Gneiss.Log;
   package Log_Client is new Gneiss_Log.Client;
   package Memory is new Gneiss.Memory (Character, Positive, String);

   Log     : Gneiss_Log.Client_Session;
   Mem     : Memory.Client_Session;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String;
                     Ctx     : in out Gneiss_Log.Client_Session) with
      Pre  => Memory.Initialized (Session)
              and then Gneiss_Log.Initialized (Ctx),
      Post => Memory.Initialized (Session)
              and then Gneiss_Log.Initialized (Ctx),
      Global => null;

   package Memory_Client is new Memory.Client (Gneiss_Log.Client_Session, Modify);

   procedure Modify is new Memory_Client.Modify (Gneiss_Log.Initialized);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Log_Client.Initialize (Log, Cap, "log_memory");
      Memory_Client.Initialize (Mem, Cap, "shared", 4096);
      if Gneiss_Log.Initialized (Log) and Memory.Initialized (Mem) then
         Modify (Mem, Log);
         Main.Vacate (Cap, Main.Success);
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String;
                     Ctx     : in out Gneiss_Log.Client_Session)
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
      Log_Client.Info (Ctx, Prefix & Data (Data'First .. Last));
   end Modify;

   procedure Destruct
   is
   begin
      Memory_Client.Finalize (Mem);
      Log_Client.Finalize (Log);
   end Destruct;

end Component;
