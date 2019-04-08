
with Ada.Unchecked_Conversion;
with Cai.Log;
with Cai.Log.Client;
with Cai.Block;
with Cai.Block.Client;
with LSC.AES_Generic;
with LSC.AES_Generic.CBC;
with Permutation;
with Correctness;

package body Component with
   SPARK_Mode
is

   type Byte is mod 2 ** 8;
   type Unsigned_Long is range 0 .. 2 ** 63 - 1;
   type Buffer is array (Unsigned_Long range <>) of Byte;

   package Block is new Cai.Block (Byte, Unsigned_Long, Buffer);

   use all type Block.Id;
   use all type Block.Count;

   package Block_Permutation is new Permutation (Block.Id);

   Log : Cai.Log.Client_Session;

   package Block_Client is new Block.Client (Event);

   Client : Block.Client_Session;

   function Next (Current : Block.Id) return Block.Id;

   function Next (Current : Block.Id) return Block.Id
   is
      Next_Block : Block.Id := Current + Block.Count'(1);
   begin
      if Block_Permutation.Has_Element then
         Block_Permutation.Next (Next_Block);
      else
         Cai.Log.Client.Error (Log, "Block permutation exceeded, increasing block number.");
      end if;
      return Next_Block;
   end Next;

   procedure PR_Block (B : in out Buffer;
                       I :        Block.Id);

   procedure PR_Block (B : in out Buffer;
                       I :        Block.Id)
   is
      function CBC_Key is new LSC.AES_Generic.Enc_Key (Unsigned_Long,
                                                       Byte,
                                                       Buffer);
      procedure CBC is new LSC.AES_Generic.CBC.Encrypt (Unsigned_Long,
                                                        Byte,
                                                        Buffer,
                                                        Unsigned_Long,
                                                        Byte,
                                                        Buffer);
      subtype Id is Buffer (1 .. 8);
      function Convert_Id is new Ada.Unchecked_Conversion (Block.Id, Id);
      Null_Block : constant Buffer (1 .. B'Length) := (others => 0);
      IV : Buffer (1 .. 16) := (others => 0);
      Key : constant Buffer (1 .. 128) := (others => 16#42#);
      --  This is no cryptographically secure encryption and only used to generate pseudo random blocks
   begin
      IV (1 .. 8) := Convert_Id (I);
      CBC (Null_Block, IV, CBC_Key (Key, LSC.AES_Generic.L128), B);
   end PR_Block;

   package Disk_Test is new Correctness (Block, Block_Client, Next, PR_Block);

   Data : Disk_Test.Test_State;

   procedure Construct (Cap : Cai.Types.Capability)
   is
      Count : Long_Integer;
      Size  : Long_Integer;
   begin
      Cai.Log.Client.Initialize (Log, Cap, "Correctness");
      Cai.Log.Client.Info (Log, "Correctness");
      Block_Client.Initialize (Client, Cap, "");
      Count := Long_Integer (Block_Client.Block_Count (Client));
      Size  := Long_Integer (Block_Client.Block_Size (Client));
      Cai.Log.Client.Info (Log, "Running correctness test over "
                                & Cai.Log.Image (Count)
                                & " blocks of "
                                & Cai.Log.Image (Size)
                                & " byte size ("
                                & Disk_Test.Byte_Image (Count * Size)
                                & ")...");
      Disk_Test.Initialize (Client, Data, Log);
      Event;
   end Construct;

   Success     : Boolean := True;
   First_Write : Boolean := True;
   First_Read  : Boolean := True;

   procedure Event
   is
   begin
      if
         Success
         and not Disk_Test.Bounds_Check_Finished (Data)
      then
         Disk_Test.Bounds_Check (Client, Data, Success, Log);
      end if;

      if
         Success
         and Disk_Test.Bounds_Check_Finished (Data)
         and not Disk_Test.Write_Finished (Data)
      then
         if First_Write then
            Block_Permutation.Initialize (Block.Id (Block_Client.Block_Count (Client) - 1));
            First_Write := False;
         end if;
         Disk_Test.Write (Client, Data, Success, Log);
      end if;

      if
         Success
         and Disk_Test.Bounds_Check_Finished (Data)
         and Disk_Test.Write_Finished (Data)
         and not Disk_Test.Read_Finished (Data)
      then
         if First_Read then
            Block_Permutation.Initialize (Block.Id (Block_Client.Block_Count (Client) - 1));
            First_Read := False;
         end if;
         Disk_Test.Read (Client, Data, Success, Log);
      end if;

      if
         Success
         and Disk_Test.Bounds_Check_Finished (Data)
         and Disk_Test.Write_Finished (Data)
         and Disk_Test.Read_Finished (Data)
         and not Disk_Test.Compare_Finished (Data)
      then
         Disk_Test.Compare (Data, Success);
      end if;

      if
         (Disk_Test.Bounds_Check_Finished (Data)
          and Disk_Test.Write_Finished (Data)
          and Disk_Test.Read_Finished (Data)
          and Disk_Test.Compare_Finished (Data))
         or not Success
      then
         Cai.Log.Client.Info (Log, "Correctness test "
                                   & (if Success then "succeeded." else "failed."));
      end if;
   end Event;

end Component;
