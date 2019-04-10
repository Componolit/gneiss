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
   type Byte is (<>);
   --  Buffer element type, must be 8bit in size
   type Buffer_Index is range <>;
   --  Buffer index type
   type Buffer is array (Buffer_Index range <>) of Byte;
   --  Buffer type to be used with all operations of this instance
package Cai.Block
   with SPARK_Mode
is
   pragma Compile_Time_Error (Byte'Size /= 8, "Byte must have a size of 8 bit.");

   type Byte_Length is range 0 .. 2 ** 63 - 1
      with Size => 64;
   type Id is mod 2 ** 64
      with Size => 64;
   type Count is range 0 .. 2 ** 63 - 1
      with Size => 64;
   type Size is range 0 .. 2 ** 32 - 1
      with Size => 64;

   function "*" (Left : Count; Right : Size) return Byte_Length is
      (Byte_Length (Left * Count (Right)));
   function "*" (Left : Size; Right : Count) return Byte_Length is
      (Right * Left);
   function "*" (Left : Count; Right : Size) return Buffer_Index is
      (Buffer_Index (Left * Count (Right)));
   function "*" (Left : Size; Right : Count) return Buffer_Index is
      (Right * Left);
   function "+" (Left : Id; Right : Count) return Id is
      (Left + Id (Right));
   function "-" (Left : Id; Right : Count) return Id is
      (Left - Id (Right));
   function "-" (Left : Id; Right : Id) return Count is
      (Count (Left) - Count (Right)) with
      Pre => Left >= Right;

   type Request_Kind is (None, Read, Write, Sync, Trim);
   --  Type of a block request, None denotes an invalid request
   type Request_Status is (Raw, Ok, Error, Acknowledged);
   --  Status of a block request, Raw denotes a newly created and not yet handled request

   type Private_Data is private;
   --  Platform specific data
   Null_Data : constant Private_Data;

   type Client_Session is limited private;
   type Dispatcher_Session is limited private;
   type Server_Session is limited private;
   --  Session types, represent actual session objects

   type Client_Instance is private;
   type Dispatcher_Instance is private;
   type Server_Instance is private;
   --  Session instances, represent unique identifiers of session objects

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
