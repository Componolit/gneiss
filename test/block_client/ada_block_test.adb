
with Cai.Block;
with Cai.Block.Client;
with Cai.Block.Client.Jobs;
with Cai.Log;
with Cai.Log.Client;

package body Ada_Block_Test with
  SPARK_Mode
is

   package Block is new Cai.Block (Character, Positive, String);
   package Block_Client is new Block.Client (Run);

   use all type Block.Count;
   use all type Block.Size;
   use all type Block.Request_Kind;

   Client : Block.Client_Session;
   Log    : Cai.Log.Client_Session;

   Job_Size  : constant Block.Count := 32;

   procedure Write (Jid    :        Block.Job_Id;
                    Bsize  :        Block.Size;
                    Data   :    out String;
                    Length : in out Block.Count;
                    Offset :        Block.Count);

   procedure Read (Jid    :        Block.Job_Id;
                   Bsize  :        Block.Size;
                   Data   :        String;
                   Length : in out Block.Count;
                   Offset :        Block.Count);

   package Jobs is new Block_Client.Jobs (Read, Write);

   procedure Write (Jid    :        Block.Job_Id;
                    Bsize  :        Block.Size;
                    Data   :    out String;
                    Length : in out Block.Count;
                    Offset :        Block.Count)
   is
      pragma Unreferenced (Jid);
   begin
      for I in 0 .. Length - 1 loop
         Data (Data'First + (I * Bsize) .. Data'First + ((I + 1) * Bsize - 1)) :=
            (others => Character'Val (33 + Integer (Offset + I) mod 93));
      end loop;
   end Write;

   procedure Read (Jid    :        Block.Job_Id;
                   Bsize  :        Block.Size;
                   Data   :        String;
                   Length : in out Block.Count;
                   Offset :        Block.Count)
   is
      pragma Unreferenced (Jid);
      pragma Unreferenced (Offset);
   begin
      for I in 0 .. Length * (Bsize / 64) loop
         Cai.Log.Client.Info (Log, Data (Data'First + I * 64 .. Data'First + (I + 1) * 64 - 1));
      end loop;
   end Read;

   Job : Jobs.Job := Jobs.Create;

   procedure Construct (Cap : Cai.Types.Capability)
   is
   begin
      Cai.Log.Client.Initialize (Log, Cap, "Ada_Block_Test");
      if Cai.Log.Client.Initialized (Log) then
         Cai.Log.Client.Info (Log, "Ada block test");
      end if;
      Block_Client.Initialize (Client, Cap, "ada test client");
      Jobs.Initialize (Job, Client, Block.Write, 0, Job_Size);
      Run;
   end Construct;

   Written : Boolean := False;

   procedure Run is
      use all type Jobs.Job_Status;
   begin
      if
         Cai.Log.Client.Initialized (Log)
         and Block_Client.Initialized (Client)
      then
         if Jobs.Status (Job) = Jobs.Pending then
            Jobs.Run (Job, Client);
         end if;
         if Jobs.Status (Job) in Jobs.Ok .. Jobs.Error then
            Jobs.Release (Job, Client);
            if not Written then
               Written := True;
               Jobs.Initialize (Job, Client, Block.Read, 0, Job_Size);
               Jobs.Run (Job, Client);
            end if;
         end if;
      end if;
   end Run;

end Ada_Block_Test;
