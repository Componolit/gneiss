
with System;
private with Cai.Internal.Block;

package Cai.Block
   with SPARK_Mode
is
   type Unsigned_Long is range 0 .. 2 ** 63 - 1
      with Size => 64;
   type Id is mod 2 ** 64
      with Size => 64;
   type Count is range 0 .. 2 ** 63 - 1
      with Size => 64;
   type Size is range 0 .. 2 ** 32 - 1
      with Size => 64;
   type Byte is mod 2 ** 8
      with Size => 8;
   type Buffer is array (Unsigned_Long range <>) of Byte;

   type Request_Kind is (None, Read, Write);
   type Request_Status is (Raw, Ok, Error, Acknowledged);

   type Private_Data is private;
   Null_Data : constant Private_Data;

   type Request (Kind : Request_Kind := None) is record
      Priv : Private_Data;
      case Kind is
         when None =>
            null;
         when Read | Write =>
            Start : Id;
            Length : Count;
            Status : Request_Status;
      end case;
   end record;

   subtype Context is System.Address;


private

   type Private_Data is new Cai.Internal.Block.Private_Data;
   Null_Data : constant Private_Data := Private_Data (Cai.Internal.Block.Null_Data);

end Cai.Block;
