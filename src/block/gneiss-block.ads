--
--  @summary Block interface declarations
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss_Internal.Block;

generic
   pragma Warnings (Off, "* is not referenced");

   --  Buffer element type, must be 8bit in size
   type Byte is (<>);

   --  Buffer index type
   type Buffer_Index is range <>;

   --  Buffer type to be used with all operations of this instance
   type Buffer is array (Buffer_Index range <>) of Byte;

   --  Max 32bit request identifier
   type Request_Id is (<>);

   pragma Warnings (On, "* is not referenced");
package Gneiss.Block with
   SPARK_Mode
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
      (Byte_Length (Left * Count (Right))) with
      Pre => (if Right /= 0 then Count'Last / Count (Right) >= Left else True);

   --  "*" Operator for block count and size
   --
   --  @param Left   Block size
   --  @param Right  Block count
   --  @return       Byte size of all blocks
   function "*" (Left : Size; Right : Count) return Byte_Length is
      (Right * Left) with
      Pre => (if Right /= 0 then Count'Last / Right >= Count (Left) else True);

   --  "*" Operator for block count and size
   --
   --  @param Left   Block size
   --  @param Right  Block count
   --  @return       Buffer length
   function "*" (Left : Count; Right : Size) return Buffer_Index is
      (Buffer_Index (Left * Count (Right))) with
      Pre => (if Right /= 0 then Count'Last / Count (Right) >= Left else True)
             and then Left * Count (Right) in Count (Buffer_Index'First) .. Count (Buffer_Index'Last);

   --  "*" Operator for block count and size
   --
   --  @param Left   Block size
   --  @param Right  Block count
   --  @return       Buffer length
   function "*" (Left : Size; Right : Count) return Buffer_Index is
      (Right * Left) with
      Pre => (if Right /= 0 then Count'Last / Right >= Count (Left) else True)
             and then Count (Left) * Right in Count (Buffer_Index'First) .. Count (Buffer_Index'Last);

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

   --  Rename default operator "-" for Id to use it in its new implementation
   --
   --  @param Left   Block Id
   --  @param Right  Block Id
   --  @return       Block Id difference of type Id
   function Subtract (Left : Id; Right : Id) return Id renames "-";

   --  "-" Operator for Block Ids
   --
   --  @param Left   Block Id
   --  @param Right  Block Id
   --  @return       Offset between Left and Right
   function "-" (Left : Id; Right : Id) return Count is
      (Count (Subtract (Left, Right))) with
      Pre => Left >= Right and Subtract (Left, Right) in Id (Count'First) .. Id (Count'Last);

   --  Result type for request allocation
   --
   --  @value Success        The request has been successfully allocated.
   --  @value Retry          The platform currently cannot allocate this request, but it might be possible later.
   --  @value Out_Of_Memory  There is currently insufficient memory available to allocate the requests data
   --                        section. This can mean that the request is too large to fit the available memory
   --                        altogether or that the buffer is currently too full to take that request. Either way
   --                        this result signals to split up the request into smaller ones.
   --  @value Unsupported    These request parameters cannot be handled at all. This happens mostly for
   --                        operations that are possibly not supported such as Sync and Trim.
   type Result is (Success, Retry, Out_Of_Memory, Unsupported);

   --  Type of a block request
   --
   --  @value None       Invalid request
   --  @value Read       Read request
   --  @value Write      Write request
   --  @value Sync       Sync request
   --  @value Trim       Trim request
   --  @value Undefined  Platform specific request that cannot be used but needs to be handled
   type Request_Kind is (None, Read, Write, Sync, Trim, Undefined);

   --  Status of a block request
   --
   --  @value Raw           Newly created request
   --  @value Allocated     Request has been successfully allocated
   --  @value Pending       Request is in flight
   --  @value Ok            Successfully handled request
   --  @value Error         Failed request
   type Request_Status is (Raw, Allocated, Pending, Ok, Error);

   --  Session types, represent actual session objects
   type Client_Session is limited private;
   type Dispatcher_Session is limited private;
   type Server_Session is limited private;

   --  Dispatcher capability used to enforce scope for dispatcher session procedures
   type Dispatcher_Capability is limited private;

   --  Gets the sessions current status
   --
   --  @param Session  Client session
   --  @return         Session initialized
   function Initialized (Session : Client_Session) return Boolean with
      Annotate => (GNATprove, Terminating);

   --  Get the sessions index
   --
   --  @param Session  Client session
   --  @return         Index option that can be invalid
   function Index (Session : Client_Session) return Session_Index_Option with
      Annotate => (GNATprove, Terminating);

   --  Check if the block device is writable
   --
   --  @param C  Client session instance
   --  @return   True if the block client is writable
   function Writable (C : Client_Session) return Boolean with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C);

   --  Get the total number of blocks of the device
   --
   --  @param C  Client session instance
   --  @return   Number of blocks on the device
   function Block_Count (C : Client_Session) return Count with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C);

   --  Get the block size in bytes
   --
   --  @param C  Client session instance
   --  @return   Size of a single block in size
   function Block_Size (C : Client_Session) return Size with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C);

   --  Check if S is initialized
   --
   --  @param S  Server session instance
   --  @return   True if the server session is initialized
   function Initialized (S : Server_Session) return Boolean with
      Annotate => (GNATprove, Terminating);

   --  Get the sessions index
   --
   --  @param Session  Server session
   --  @return         Index option that can be invalid
   function Index (Session : Server_Session) return Session_Index_Option with
      Annotate => (GNATprove, Terminating);

   --  Checks if D is initialized
   --
   --  @param D  Dispatcher session instance
   --  @return   True if D is initialized
   function Initialized (D : Dispatcher_Session) return Boolean with
      Annotate => (GNATprove, Terminating);

   --  Get the sessions index
   --
   --  @param Session  Dispatcher session
   --  @return         Index option that can be invalid
   function Index (Session : Dispatcher_Session) return Session_Index_Option with
      Annotate => (GNATprove, Terminating);

   function Accepted (D : Dispatcher_Session) return Boolean with
      Ghost,
      Import,
      Pre => Initialized (D);

private

   type Client_Session is new Gneiss_Internal.Block.Client_Session;
   type Dispatcher_Session is new Gneiss_Internal.Block.Dispatcher_Session;
   type Server_Session is new Gneiss_Internal.Block.Server_Session;
   type Dispatcher_Capability is new Gneiss_Internal.Block.Dispatcher_Capability;

end Gneiss.Block;
