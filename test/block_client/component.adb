
with Componolit.Interfaces.Block;
with Componolit.Interfaces.Block.Client;
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;
with Componolit.Interfaces.Strings_Generic;

package body Component with
  SPARK_Mode
is

   type Request_Id is mod 8;

   package Block is new Componolit.Interfaces.Block (Character, Positive, String);

   procedure Write (C :     Block.Client_Instance;
                    R :     Request_Id;
                    D : out String);

   procedure Read (C : Block.Client_Instance;
                   R : Request_Id;
                   D : String);

   function Image is new Componolit.Interfaces.Strings_Generic.Image_Ranged (Block.Count);
   function Image is new Componolit.Interfaces.Strings_Generic.Image_Ranged (Block.Size);

   package Block_Client is new Block.Client (Request_Id, Run, Read, Write);

   type Request_Cache_Type is array (Request_Id'Range) of Block_Client.Request;

   Request_Cache : Request_Cache_Type := (others => Block_Client.Null_Request);

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

   procedure Write (C :     Block.Client_Instance;
                    R :     Request_Id;
                    D : out String)
   is
      pragma Unreferenced (C);
      use type Block.Id;
   begin
      D := (others => Character'Val (33 + Integer (Block_Client.Start (Request_Cache (R)) mod 93)));
   end Write;

   procedure Single (S         : in out State;
                     Operation :        Block.Request_Kind)
   is
      Block_Size : constant Block.Size := Block_Client.Block_Size (Client);
   begin
      if
         Block_Size <= 4096 and Block_Size >= 256
      then
         for I in Request_Cache'Range loop

            if Block_Client.Status (Request_Cache (I)) = Block.Pending then
               Block_Client.Update_Request (Client, Request_Cache (I));
               if Block_Client.Status (Request_Cache (I)) = Block.Ok then
                  case Block_Client.Kind (Request_Cache (I)) is
                     when Block.Write =>
                        S.Acked := S.Acked + 1;
                     when Block.Read =>
                        if Block_Client.Length (Request_Cache (I)) = 1 then
                           Block_Client.Read (Client, Request_Cache (I));
                        else
                           Componolit.Interfaces.Log.Client.Error (Log, "Read failed.");
                        end if;
                        S.Acked := S.Acked + 1;
                     when others =>
                        null;
                  end case;
                  Block_Client.Release (Client, Request_Cache (I));
               elsif Block_Client.Status (Request_Cache (I)) = Block.Error then
                  Componolit.Interfaces.Log.Client.Error (Log, "Request failed");
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
                                              I);
            end if;
            if Block_Client.Status (Request_Cache (I)) = Block.Allocated then
               S.Sent := S.Sent + 1;
               Block_Client.Enqueue (Client, Request_Cache (I));
            end if;

         end loop;
         Block_Client.Submit (Client);
      else
         Componolit.Interfaces.Log.Client.Error (Log, "Failed to send requests. Invalid block size.");
      end if;
   end Single;

   procedure Read (C : Block.Client_Instance;
                   R : Request_Id;
                   D : String)
   is
      pragma Unreferenced (C);
      pragma Unreferenced (R);
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
               --  FIXME: Calls of Image with explicit default parameters
               --  Componolit/Workarounds#2
               Componolit.Interfaces.Log.Client.Info (Log, "Block device with "
                                    & Image (Block_Client.Block_Count (Client), 10, True)
                                    & " blocks of size "
                                    & Image (Block_Client.Block_Size (Client), 10, True));
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
