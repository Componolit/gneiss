
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

   function "*" (Left : Count; Right : Size) return Unsigned_Long is
      (Unsigned_Long (Left * Count (Right)));
   function "*" (Left : Size; Right : Count) return Unsigned_Long is
      (Right * Left);
   function "+" (Left : Id; Right : Count) return Id is
      (Left + Id (Right));
   function "-" (Left : Id; Right : Count) return Id is
      (Left - Id (Right));
   function "-" (Left : Id; Right : Id) return Count is
      (Count (Left) - Count (Right)) with
      Pre => Left >= Right;

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

   type Client_Session is limited private;
   type Dispatcher_Session is limited private;
   type Server_Session is limited private;
   type Client_Instance is private;
   type Dispatcher_Instance is private;
   type Server_Instance is private;

private

   type Private_Data is new Cai.Internal.Block.Private_Data;
   Null_Data : constant Private_Data := Private_Data (Cai.Internal.Block.Null_Data);
   type Client_Session is new Cai.Internal.Block.Client_Session;
   type Dispatcher_Session is new Cai.Internal.Block.Dispatcher_Session;
   type Server_Session is new Cai.Internal.Block.Server_Session;
   type Client_Instance is new Cai.Internal.Block.Client_Instance;
   type Dispatcher_Instance is new Cai.Internal.Block.Dispatcher_Instance;
   type Server_Instance is new Cai.Internal.Block.Server_Instance;

end Cai.Block;
