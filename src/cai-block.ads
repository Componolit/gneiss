--
--  @summary Block interface declarations
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Cai.Internal.Block;

pragma Warnings (Off, "type ""Buffer"" is not referenced");
--  Buffer is only provided to be used in child packages

generic
   --  Buffer element type, must be 8bit in size
   type Byte is (<>);
   --  Buffer index type
   type Buffer_Index is range <>;
   --  Buffer type to be used with all operations of this instance
   type Buffer is array (Buffer_Index range <>) of Byte;
package Cai.Block
   with SPARK_Mode
is
   pragma Compile_Time_Error (Byte'Size /= 8, "Byte must have a size of 8 bit.");

   --  Number of Bytes
   type Byte_Length is range 0 .. 2 ** 63 - 1
      with Size => 64;

   --  Block Id
   type Id is mod 2 ** 64
      with Size => 64;

   --  Amount of blocks
   type Count is range 0 .. 2 ** 63 - 1
      with Size => 64;

   --  Size of a block in bytes
   type Size is range 0 .. 2 ** 32 - 1
      with Size => 64;

   --  "*" Operator for block count and size
   --
   --  @param Left   Block count
   --  @param Right  Block size
   --  @return       Byte size of all blocks
   function "*" (Left : Count; Right : Size) return Byte_Length is
      (Byte_Length (Left * Count (Right)));

   --  "*" Operator for block count and size
   --
   --  @param Left   Block size
   --  @param Right  Block count
   --  @return       Byte size of all blocks
   function "*" (Left : Size; Right : Count) return Byte_Length is
      (Right * Left);

   --  "*" Operator for block count and size
   --
   --  @param Left   Block size
   --  @param Right  Block count
   --  @return       Buffer length
   function "*" (Left : Count; Right : Size) return Buffer_Index is
      (Buffer_Index (Left * Count (Right)));

   --  "*" Operator for block count and size
   --
   --  @param Left   Block size
   --  @param Right  Block count
   --  @return       Buffer length
   function "*" (Left : Size; Right : Count) return Buffer_Index is
      (Right * Left);

   --  "+" Operator for block Id and count
   --
   --  @param Left   Block Id
   --  @param Right  Block count
   --  @return       Block Id that has offset Right from Left
   function "+" (Left : Id; Right : Count) return Id is
      (Left + Id (Right));

   --  "-" Operator for block Id and count
   --
   --  @param Left   Block Id
   --  @param Right  Block count
   --  @return       Block Id that has offset -Right from Left
   function "-" (Left : Id; Right : Count) return Id is
      (Left - Id (Right));

   --  "-" Operator for Block Ids
   --
   --  @param Left   Block Id
   --  @param Right  Block Id
   --  @return       Offset between Left and Right
   function "-" (Left : Id; Right : Id) return Count is
      (Count (Left) - Count (Right)) with
      Pre => Left >= Right;

   --  Type of a block request
   --
   --  @value None   Invalid request
   --  @value Read   Read request
   --  @value Write  Write request
   --  @value Sync   Sync request
   --  @value Trim   Trim request
   type Request_Kind is (None, Read, Write, Sync, Trim);

   --  Status of a block request
   --
   --  @value Raw           Newly created request
   --  @value Ok            Successfully handled request
   --  @value Error         Failed request
   --  @value Acknowledged  Request has been acknoweledged by the platform, only relevant for server
   type Request_Status is (Raw, Ok, Error, Acknowledged);

   --  Platform specific data
   type Private_Data is private;
   Null_Data : constant Private_Data;

   --  Session types, represent actual session objects
   type Client_Session is limited private;
   type Dispatcher_Session is limited private;
   type Server_Session is limited private;

   --  Session instances, represent unique identifiers of session objects
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
