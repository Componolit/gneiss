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

private with Componolit.Interfaces.Internal.Block;

generic
   pragma Warnings (Off, "* is not referenced");

   --  Buffer element type, must be 8bit in size
   type Byte is (<>);

   --  Buffer index type
   type Buffer_Index is range <>;

   --  Buffer type to be used with all operations of this instance
   type Buffer is array (Buffer_Index range <>) of Byte;

   --  max 32bit request identifier
   type Request_Id is (<>);

   pragma Warnings (On, "* is not referenced");
package Componolit.Interfaces.Block with
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

   --  Block client request
   type Client_Request is limited private;

   --  Block server request
   type Server_Request is limited private;

   --  Session types, represent actual session objects
   type Client_Session is limited private;
   type Dispatcher_Session is limited private;
   type Server_Session is limited private;

   --  Session instances, represent unique identifiers of session objects
   type Client_Instance is private;
   type Dispatcher_Instance is private;
   type Server_Instance is private;

   --  Dispatcher capability used to enforce scope for dispatcher session procedures
   type Dispatcher_Capability is limited private;

   --  Create empty request
   --
   --  @return  empty, uninitialized request
   function Null_Request return Client_Request with
      Annotate => (GNATprove, Terminating),
      Post => Status (Null_Request'Result) = Raw;

   --  Get request type
   --
   --  @param R  Request
   --  @return   Request type
   function Kind (R : Client_Request) return Request_Kind with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) /= Raw;

   --  Get request status
   --
   --  @param R  Request
   --  @return   Request status
   function Status (R : Client_Request) return Request_Status with
      Annotate => (GNATprove, Terminating);

   --  Get request start block
   --
   --  @param R  Request
   --  @return   First block id to be handled by this request
   function Start (R : Client_Request) return Id with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) not in Raw | Error;

   --  Get request length
   --
   --  @param R  Request
   --  @return   Number of consecutive blocks handled by this request
   function Length (R : Client_Request) return Count with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) not in Raw | Error;

   --  Get request identifier
   --
   --  @param R  Request
   --  @return   Unique identifier of the request
   function Identifier (R : Client_Request) return Request_Id with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) not in Raw | Error;

   --  Return True if C is initialized
   --
   --  @param C  Client session instance
   function Initialized (C : Client_Session) return Boolean with
      Annotate => (GNATprove, Terminating),
      Post => Initialized'Result = Initialized (Instance (C));

   --  Check if the client session of C is initialized
   --
   --  @param C  Client instance
   --  @return   True if the session that belongs to C is initialized
   function Initialized (C : Client_Instance) return Boolean with
      --  Ghost, --  Componolit/Workarounds#3
      Annotate => (GNATprove, Terminating);

   --  Create uninitialized client session
   --
   --  @return Uninitialized client session
   function Create return Client_Session with
      Annotate => (GNATprove, Terminating);

   --  Get the instance ID of C
   --
   --  @param C  Client session instance
   function Instance (C : Client_Session) return Client_Instance with
      Annotate => (GNATprove, Terminating);

   function Instance (R : Client_Request) return Client_Instance with
      Pre => Status (R) /= Raw;

   --  Check if the block device is writable
   --
   --  @param C  Client session instance
   function Writable (C : Client_Session) return Boolean with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C);

   --  Get the total number of blocks of the device
   --
   --  @param C  Client session instance
   function Block_Count (C : Client_Session) return Count with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C);

   --  Get the block size in bytes
   --
   --  @param C  Client session instance
   function Block_Size (C : Client_Session) return Size with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C);

   --  Create empty request
   --
   --  @return  empty, uninitialized request
   function Null_Request return Server_Request with
      Annotate => (GNATprove, Terminating),
      Post => Status (Null_Request'Result) = Raw;

   --  Get request type
   --
   --  @param R  Request
   --  @return   Request type
   function Kind (R : Server_Request) return Request_Kind with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) = Pending;

   --  Get request status
   --
   --  @param R  Request
   --  @return   Request status
   function Status (R : Server_Request) return Request_Status with
      Annotate => (GNATprove, Terminating);

   --  Get request start block
   --
   --  @param R  Request
   --  @return   First block id to be handled by this request
   function Start (R : Server_Request) return Id with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) = Pending;

   --  Get request length in blocks
   --
   --  @param R  Request
   --  @return   Number of consecutive blocks handled by this request
   function Length (R : Server_Request) return Count with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) = Pending;

   --  Check if S is initialized
   --
   --  @param S  Server session instance
   function Initialized (S : Server_Session) return Boolean with
      Annotate => (GNATprove, Terminating),
      Post => Initialized'Result = Initialized (Instance (S));

   --  Check if the Server session of S is initialized
   --
   --  @param S  Server instance
   --  @return   True if the session that belongs to S is initialized
   function Initialized (S : Server_Instance) return Boolean with
      --  Ghost, --  Componolit/Workarounds#3
      Inline_Always,
      Annotate => (GNATprove, Terminating);

   --  Create new server session
   --
   --  @return Uninitialized server session
   function Create return Server_Session;

   --  Get the instance ID of S
   --
   --  @param S  Server session instance
   function Instance (S : Server_Session) return Server_Instance;

   --  Checks if D is initialized
   --
   --  @param D  Dispatcher session instance
   --  @return   True if D is initialized
   function Initialized (D : Dispatcher_Session) return Boolean with
      Post => Initialized'Result = Initialized (Instance (D));

   --  Check if the Dispatcher session of D is initialized
   --
   --  @param D  Dispatcher instance
   --  @return   True if the session that belongs to D is initialized
   function Initialized (D : Dispatcher_Instance) return Boolean with
      --  Ghost, --  Componolit/Workarounds#3
      Annotate => (GNATprove, Terminating);

   --  Create new dispatcher session
   --
   --  @return Uninitialized dispatcher session
   function Create return Dispatcher_Session;

   --  Return the instance ID of D
   --
   --  @param D  Dispatcher session instance
   --  @return   Instance identifier of D
   function Instance (D : Dispatcher_Session) return Dispatcher_Instance;

   function Accepted (D : Dispatcher_Instance) return Boolean with
      Ghost,
      Import,
      Pre => Initialized (D);

private

   type Client_Session is new Componolit.Interfaces.Internal.Block.Client_Session;
   type Dispatcher_Session is new Componolit.Interfaces.Internal.Block.Dispatcher_Session;
   type Server_Session is new Componolit.Interfaces.Internal.Block.Server_Session;
   type Client_Instance is new Componolit.Interfaces.Internal.Block.Client_Instance;
   type Dispatcher_Instance is new Componolit.Interfaces.Internal.Block.Dispatcher_Instance;
   type Server_Instance is new Componolit.Interfaces.Internal.Block.Server_Instance;
   type Dispatcher_Capability is new Componolit.Interfaces.Internal.Block.Dispatcher_Capability;

   type Client_Request is new Componolit.Interfaces.Internal.Block.Client_Request;
   type Server_Request is new Componolit.Interfaces.Internal.Block.Server_Request;

end Componolit.Interfaces.Block;
