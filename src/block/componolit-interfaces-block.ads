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

   --  Max 32bit session identifier
   type Session_Id is (<>);

   --  Max 32bit request identifier
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

   --  Dispatcher capability used to enforce scope for dispatcher session procedures
   type Dispatcher_Capability is limited private;

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

   --  Check if a request is assigned to this session
   --
   --  When a request is allocated it gets assigned to the session that is used for allocation.
   --  It can then only be used by this session.
   --
   --  @param C  Client session instance
   --  @param R  Request to check
   --  @return   True if the R is assigned to C
   function Assigned (C : Client_Session;
                      R : Client_Request) return Boolean with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C)
             and then Status (R) /= Raw;

   --  Return True if C is initialized
   --
   --  @param C  Client session instance
   --  @return   True if initialized
   function Initialized (C : Client_Session) return Boolean with
      Annotate => (GNATprove, Terminating);

   --  Return session identifier
   --
   --  @param C  Client session instance
   --  @return   Identifier passed on initialization
   function Identifier (C : Client_Session) return Session_Id with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C);

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

   --  Helper function to check if the assigned session Id is valid
   --
   --  This property is also inherited by Initialized. Yet some callback procedures are called
   --  before Initialized is true but still require a valid session Id. This property is necessary
   --  but not sufficient for Initialized.
   --
   --  @param S  Server Session Instance
   --  @return   True if the internal representation of the session id yields a valid Session_Id
   function Valid (S : Server_Session) return Boolean with
      Annotate => (GNATprove, Terminating);

   --  Check if a request is assigned to this session
   --
   --  When a request is allocated it gets assigned to the session that is used for allocation.
   --  It can then only be used by this session.
   --
   --  @param S  Server session instance
   --  @param R  Request to check
   --  @return   True if the R is assigned to S
   function Assigned (S : Server_Session;
                      R : Server_Request) return Boolean with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (S)
             and then Status (R) /= Raw;

   --  Check if S is initialized
   --
   --  @param S  Server session instance
   --  @return   True if the server session is initialized
   function Initialized (S : Server_Session) return Boolean with
      Annotate => (GNATprove, Terminating);

   --  Return session identifier
   --
   --  @param S  Server session instance
   --  @return   Identifier passed on initialization
   function Identifier (S : Server_Session) return Session_Id with
      Annotate => (GNATprove, Terminating),
      Pre => Valid (S);

   --  Checks if D is initialized
   --
   --  @param D  Dispatcher session instance
   --  @return   True if D is initialized
   function Initialized (D : Dispatcher_Session) return Boolean with
      Annotate => (GNATprove, Terminating);

   --  Return session identifier
   --
   --  @param D  Dispatcher session instance
   --  @return   Identifier passed on initialization
   function Identifier (D : Dispatcher_Session) return Session_Id with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (D);

   function Accepted (D : Dispatcher_Session) return Boolean with
      Ghost,
      Import,
      Pre => Initialized (D);

private

   type Client_Session is new Componolit.Interfaces.Internal.Block.Client_Session;
   type Dispatcher_Session is new Componolit.Interfaces.Internal.Block.Dispatcher_Session;
   type Server_Session is new Componolit.Interfaces.Internal.Block.Server_Session;
   type Dispatcher_Capability is new Componolit.Interfaces.Internal.Block.Dispatcher_Capability;

   type Client_Request is new Componolit.Interfaces.Internal.Block.Client_Request;
   type Server_Request is new Componolit.Interfaces.Internal.Block.Server_Request;

end Componolit.Interfaces.Block;
