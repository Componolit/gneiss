
with Componolit.Interfaces.Block;
with Componolit.Interfaces.Block.Client;
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;

package body Component with
  SPARK_Mode
is

   type Request_Id is mod 8;

   package Block is new Componolit.Interfaces.Block (Character, Positive, String);

   procedure Write (C : Block.Client_Instance;
                    B : Block.Size;
                    S : Block.Id;
                    L : Block.Count;
                    D : out String);

   procedure Read (C : Block.Client_Instance;
                   B : Block.Size;
                   S : Block.Id;
                   L : Block.Count;
                   D : String);

   package Block_Client is new Block.Client (Request_Id, Run, Read, Write);

   type Request_Cache_Type is array (Request_Id'Range) of Block_Client.Request;

   Request_Cache : Request_Cache_Type := (others => Block_Client.Create_Request);

   use all type Block.Count;
   use all type Block.Size;
   use all type Block.Request_Kind;
   use all type Block.Request_Status;

   subtype Invalid_Id is Integer range -1 .. Integer'Last;

   type State is record
      Sent  : Invalid_Id := -1;
      Acked : Invalid_Id := -1;
   end record;

   Client : Block.Client_Session;
   Log    : Componolit.Interfaces.Log.Client_Session;
   P_Cap  : Componolit.Interfaces.Types.Capability;

   Request_Count : constant Integer := 32;

   Write_State : State := (others => -1);
   Read_State  : State := (others => -1);

   function State_Finished (S : State) return Boolean is
      (S.Sent = Request_Count and S.Acked = Request_Count);

   procedure Single (S         : in out State;
                     Operation :        Block.Request_Kind) with
      Pre  => Block_Client.Initialized (Client)
              and Componolit.Interfaces.Log.Client.Initialized (Log)
              and Operation in Block.Read .. Block.Write,
      Post => Block_Client.Initialized (Client)
              and Componolit.Interfaces.Log.Client.Initialized (Log);

   procedure Write (C : Block.Client_Instance;
                    B : Block.Size;
                    S : Block.Id;
                    L : Block.Count;
                    D : out String)
   is
      pragma Unreferenced (C);
      pragma Unreferenced (B);
      pragma Unreferenced (L);
      use type Block.Id;
   begin
      D := (others => Character'Val (33 + Integer (S mod 93)));
   end Write;

   procedure Single (S         : in out State;
                     Operation :        Block.Request_Kind)
   is
      Block_Size : constant Block.Size := Block_Client.Block_Size (Client);
      Req_Cap    : Block_Client.Request_Capability;
      Req_Id     : Request_Id;
      Alloc      : Request_Id;
      Alloc_Succ : Boolean := False;
   begin
      if S.Acked < Request_Count then
         loop
            pragma Loop_Invariant (Block_Client.Initialized (Client));
            pragma Loop_Invariant (Componolit.Interfaces.Log.Client.Initialized (Log));
            pragma Loop_Invariant (Block_Client.Block_Size (Client) = Block_Size);
            Block_Client.Update_Response_Queue (Client, Req_Cap);
            exit when not Block_Client.Valid_Capability (Req_Cap);
            exit when S.Acked >= Request_Count;
            Req_Id := Block_Client.Request_Identifier (Req_Cap);
            Block_Client.Update_Request (Client, Request_Cache (Req_Id), Req_Cap);
            case Block_Client.Request_Type (Request_Cache (Req_Id)) is
               when Block.Write =>
                  if Block_Client.Request_State (Request_Cache (Req_Id)) /= Block.Ok then
                     Componolit.Interfaces.Log.Client.Error (Log, "Write failed.");
                  end if;
                  S.Acked := S.Acked + 1;
               when Block.Read =>
                  if
                     Block_Client.Request_State (Request_Cache (Req_Id)) = Block.Ok
                     and then Block_Client.Request_Length (Request_Cache (Req_Id)) = 1
                  then
                     Block_Client.Read (Client, Request_Cache (Req_Id));
                  else
                     Componolit.Interfaces.Log.Client.Error (Log, "Read failed.");
                  end if;
                  S.Acked := S.Acked + 1;
               when others =>
                  null;
            end case;
            Block_Client.Release (Client, Request_Cache (Req_Id));
         end loop;
      end if;
      if Block_Size <= 4096 and Block_Size >= 256 then
         if S.Sent < Request_Count then
            loop
               pragma Loop_Invariant (Block_Client.Initialized (Client));
               pragma Loop_Invariant (Componolit.Interfaces.Log.Client.Initialized (Log));
               pragma Loop_Invariant (S.Sent < Integer'Last);
               pragma Loop_Invariant (Block_Client.Block_Size (Client) = Block_Size);
               for I in Request_Cache'Range loop
                  if Block_Client.Request_State (Request_Cache (I)) = Block.Raw then
                     Alloc := I;
                     Alloc_Succ := True;
                     exit;
                  end if;
               end loop;
               exit when not Alloc_Succ
                         or S.Sent >= Request_Count
                         or S.Sent = Integer'Last;
               Block_Client.Allocate_Request (Client,
                                              Request_Cache (Alloc),
                                              Operation,
                                              Block.Id (S.Sent + 1),
                                              1,
                                              Alloc);
               exit when Block_Client.Request_State (Request_Cache (Alloc)) /= Block.Allocated;
               Block_Client.Enqueue (Client, Request_Cache (Alloc));
               S.Sent := S.Sent + 1;
               Alloc_Succ := False;
            end loop;
            Block_Client.Submit (Client);
         end if;
      else
         Componolit.Interfaces.Log.Client.Error (Log, "Failed to send write requests. Invalid block size.");
      end if;
   end Single;

   procedure Read (C : Block.Client_Instance;
                   B : Block.Size;
                   S : Block.Id;
                   L : Block.Count;
                   D : String)
   is
      pragma Unreferenced (C);
      pragma Unreferenced (B);
      pragma Unreferenced (S);
      pragma Unreferenced (L);
   begin
      Componolit.Interfaces.Log.Client.Info (Log, "Read succeeded:");
      if D'Length >= Componolit.Interfaces.Log.Client.Maximum_Message_Length (Log) then
         Componolit.Interfaces.Log.Client.Info
            (Log, D (D'First .. D'First + Componolit.Interfaces.Log.Client.Maximum_Message_Length (Log) - 1));
      else
         Componolit.Interfaces.Log.Client.Info (Log, D);
      end if;
   end Read;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      P_Cap := Cap;
      if not Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Ada block test");
      end if;
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Info (Log, "Ada block test");
         if not Block_Client.Initialized (Client) then
            Block_Client.Initialize (Client, Cap, "/tmp/test_disk.img");
         end if;
         if Block_Client.Initialized (Client) then
            if Componolit.Interfaces.Log.Client.Initialized (Log) then
               Componolit.Interfaces.Log.Client.Info (Log, "Block device with "
                                    & Componolit.Interfaces.Log.Image
                                         (Long_Integer (Block_Client.Block_Count (Client)))
                                    & " blocks of size "
                                    & Componolit.Interfaces.Log.Image
                                         (Long_Integer (Block_Client.Block_Size (Client))));
            end if;
            if Block_Client.Writable (Client) then
               Run;
            else
               Componolit.Interfaces.Log.Client.Error (Log, "Block device not writable, cannot run test");
               Main.Vacate (P_Cap, Main.Failure);
            end if;
         else
            Componolit.Interfaces.Log.Client.Error (Log, "Failed to initialize Block session");
            Main.Vacate (P_Cap, Main.Failure);
         end if;
      else
         Main.Vacate (P_Cap, Main.Failure);
      end if;
   end Construct;

   procedure Run is
   begin
      if
         Componolit.Interfaces.Log.Client.Initialized (Log)
         and Block_Client.Initialized (Client)
      then
         if not State_Finished (Write_State) then
            Componolit.Interfaces.Log.Client.Info (Log, "Writing...");
            Single (Write_State, Block.Write);
         end if;
         if
            State_Finished (Write_State)
            and not State_Finished (Read_State)
         then
            Componolit.Interfaces.Log.Client.Info (Log, "Reading...");
            Single (Read_State, Block.Read);
         end if;
         if
            State_Finished (Write_State)
            and State_Finished (Read_State)
         then
            Main.Vacate (P_Cap, Main.Success);
            Componolit.Interfaces.Log.Client.Info (Log, "Test finished.");
         end if;
      end if;
   end Run;

   procedure Destruct
   is
   begin
      if Block_Client.Initialized (Client) then
         Block_Client.Finalize (Client);
      end if;
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
