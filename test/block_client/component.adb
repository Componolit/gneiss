
with Componolit.Gneiss.Block;
with Componolit.Gneiss.Block.Client;
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;
with Componolit.Gneiss.Strings_Generic;

package body Component with
  SPARK_Mode
is

   type Request_Id is mod 8;

   package Block is new Componolit.Gneiss.Block (Character, Positive, String, Integer, Request_Id);

   procedure Write (C : in out Block.Client_Session;
                    R :        Request_Id;
                    D :    out String) with
      Pre => Block.Initialized (C);

   procedure Read (C : in out Block.Client_Session;
                   R :        Request_Id;
                   D :        String) with
      Pre => Block.Initialized (C);

   function Image is new Componolit.Gneiss.Strings_Generic.Image_Ranged (Block.Count);
   function Image is new Componolit.Gneiss.Strings_Generic.Image_Ranged (Block.Size);

   package Block_Client is new Block.Client (Run, Read, Write);

   type Request_Cache_Type is array (Request_Id'Range) of Block_Client.Request;

   Request_Cache : Request_Cache_Type;

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
   Log    : Componolit.Gneiss.Log.Client_Session;
   P_Cap  : Componolit.Gneiss.Types.Capability;

   Request_Count : constant Integer := 32;

   Write_State : State := (others => -1);
   Read_State  : State := (others => -1);

   function State_Finished (S : State) return Boolean is
      (S.Acked >= Request_Count);

   procedure Single (S         : in out State;
                     Operation :        Block.Request_Kind) with
      Pre  => Block.Initialized (Client)
              and then Componolit.Gneiss.Log.Initialized (Log)
              and then Operation in Block.Read .. Block.Write,
      Post => Block.Initialized (Client)
              and then Componolit.Gneiss.Log.Initialized (Log);

   procedure Write (C : in out Block.Client_Session;
                    R :        Request_Id;
                    D :    out String)
   is
      pragma Unreferenced (C);
      use type Block.Id;
   begin
      if Block_Client.Status (Request_Cache (R)) not in Block.Raw | Block.Error then
         D := (others => Character'Val (33 + Integer (Block_Client.Start (Request_Cache (R)) mod 93)));
      else
         if Componolit.Gneiss.Log.Initialized (Log) then
            Componolit.Gneiss.Log.Client.Warning (Log, "Failed to calculate content");
         end if;
         D := (others => Character'First);
      end if;
   end Write;

   procedure Single (S         : in out State;
                     Operation :        Block.Request_Kind)
   is
      Block_Size : constant Block.Size := Block.Block_Size (Client);
      Result     : Block.Result;
   begin
      if Block_Size <= 4096 and Block_Size >= 256 then
         for I in Request_Cache'Range loop
            if
               S.Acked < Request_Count
               and then Block_Client.Status (Request_Cache (I)) = Block.Pending
               and then Block_Client.Assigned (Client, Request_Cache (I))
            then
               Block_Client.Update_Request (Client, Request_Cache (I));
               if Block_Client.Status (Request_Cache (I)) = Block.Ok then
                  case Block_Client.Kind (Request_Cache (I)) is
                     when Block.Write =>
                        S.Acked := S.Acked + 1;
                     when Block.Read =>
                        if Block_Client.Length (Request_Cache (I)) = 1 then
                           Block_Client.Read (Client, Request_Cache (I));
                        else
                           Componolit.Gneiss.Log.Client.Error (Log, "Read failed.");
                        end if;
                        S.Acked := S.Acked + 1;
                     when others =>
                        null;
                  end case;
                  Block_Client.Release (Client, Request_Cache (I));
               elsif Block_Client.Status (Request_Cache (I)) = Block.Error then
                  Componolit.Gneiss.Log.Client.Error (Log, "Request failed");
                  Block_Client.Release (Client, Request_Cache (I));
               end if;
            end if;

            if
               S.Sent < Request_Count
               and then Block_Client.Status (Request_Cache (I)) = Block.Raw
            then
               Block_Client.Allocate_Request (Client,
                                              Request_Cache (I),
                                              Operation,
                                              Block.Id (S.Sent + 1),
                                              1,
                                              I,
                                              Result);
               case Result is
                  when Block.Success =>
                     S.Sent := S.Sent + 1;
                     if Block_Client.Kind (Request_Cache (I)) = Block.Write then
                        Block_Client.Write (Client, Request_Cache (I));
                     end if;
                     Block_Client.Enqueue (Client, Request_Cache (I));
                  when Block.Retry | Block.Out_Of_Memory =>
                     null;
                  when Block.Unsupported =>
                     Componolit.Gneiss.Log.Client.Error (Log, "Cannot allocate request");
                     Main.Vacate (P_Cap, Main.Failure);
               end case;
            end if;

            pragma Loop_Invariant (Block.Initialized (Client));
            pragma Loop_Invariant (Componolit.Gneiss.Log.Initialized (Log));
         end loop;
         Block_Client.Submit (Client);
      else
         Componolit.Gneiss.Log.Client.Error (Log, "Failed to send requests. Invalid block size.");
      end if;
   end Single;

   procedure Read (C : in out Block.Client_Session;
                   R :        Request_Id;
                   D :        String)
   is
      pragma Unreferenced (C);
      pragma Unreferenced (R);
   begin
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Info (Log, "Read succeeded:");
         if D'Length >= Componolit.Gneiss.Log.Maximum_Message_Length (Log) then
            Componolit.Gneiss.Log.Client.Info
               (Log, D (D'First .. D'First + (Componolit.Gneiss.Log.Maximum_Message_Length (Log) - 1)));
         else
            Componolit.Gneiss.Log.Client.Info (Log, D);
         end if;
      end if;
   end Read;

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability)
   is
   begin
      P_Cap := Cap;
      if not Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Initialize (Log, Cap, "log_block_client");
      end if;
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Info (Log, "Ada block test");
         if not Block.Initialized (Client) then
            Block_Client.Initialize (Client, Cap, "/tmp/test_disk.img", 42);
         end if;
         if Block.Initialized (Client) then
            if Componolit.Gneiss.Log.Initialized (Log) then
               --  FIXME: Calls of Image with explicit default parameters
               --  Componolit/Workarounds#2
               Componolit.Gneiss.Log.Client.Info (Log, "Block device with "
                                    & Image (Block.Block_Count (Client), 10, True)
                                    & " blocks of size "
                                    & Image (Block.Block_Size (Client), 10, True));
            end if;
            if Block.Writable (Client) then
               Run;
            else
               Componolit.Gneiss.Log.Client.Error (Log, "Block device not writable, cannot run test");
               Main.Vacate (P_Cap, Main.Failure);
            end if;
         else
            Componolit.Gneiss.Log.Client.Error (Log, "Failed to initialize Block session");
            Main.Vacate (P_Cap, Main.Failure);
         end if;
      else
         Main.Vacate (P_Cap, Main.Failure);
      end if;
   end Construct;

   procedure Run is
   begin
      if
         Componolit.Gneiss.Log.Initialized (Log)
         and Block.Initialized (Client)
      then
         if not State_Finished (Write_State) then
            Componolit.Gneiss.Log.Client.Info (Log, "Writing...");
            Single (Write_State, Block.Write);
         end if;
         if
            State_Finished (Write_State)
            and not State_Finished (Read_State)
         then
            Componolit.Gneiss.Log.Client.Info (Log, "Reading...");
            Single (Read_State, Block.Read);
         end if;
         if
            State_Finished (Write_State)
            and State_Finished (Read_State)
         then
            Main.Vacate (P_Cap, Main.Success);
            Componolit.Gneiss.Log.Client.Info (Log, "Test finished.");
         end if;
      end if;
   end Run;

   procedure Destruct
   is
   begin
      if Block.Initialized (Client) then
         Block_Client.Finalize (Client);
      end if;
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
