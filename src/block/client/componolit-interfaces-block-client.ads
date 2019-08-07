--
--  @summary Block client interface
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Componolit.Interfaces.Types;
private with Componolit.Interfaces.Internal.Block;

generic
   pragma Warnings (Off, "* is not referenced");
   --  Supress unreferenced warnings since not every platform needs this procedure

   --  max 32bit request identifier
   type Request_Id is (<>);

   --  Block client event handler
   with procedure Event;

   --  Called when a read has been triggered and data is available
   --
   --  The length of Data always corresponds to the request length in bytes (block size * block count)
   --
   --  @param C       Client session instance identifier
   --  @param Req     Request identifier of request to write
   --  @param Data    Read data
   with procedure Read (C      : Client_Instance;
                        Req    : Request_Id;
                        Data   : Buffer);

   --  Write procedure called when the platform required data to write
   --
   --  The length of Data always corresponds to the request length in bytes (block size * block count)
   --
   --  @param C       Client session instance identifier
   --  @param Req     Request identifier of request to write
   --  @param Data    Data that will be written
   with procedure Write (C      :     Client_Instance;
                         Req    :     Request_Id;
                         Data   : out Buffer);
   pragma Warnings (On, "* is not referenced");
package Componolit.Interfaces.Block.Client with
   SPARK_Mode
is

   --  Block client request
   type Request is limited private;

   --  Result type for request allocation
   --
   --  @value Success        The request has been successfully allocated.
   --  @value Retry          The platform currently cannot allocate this request, but it might be possible later.
   --  @value Out_Of_Memory  There is currently insufficient memory available to allocate the requests data
   --                        section. This can mean that the request is too large to fit the available memory
   --                        altogether or that the buffer is currently too ful to take that request. Either way
   --                        this result signals to split up the request into smaller ones.
   --  @value Unsupported    These request parameters cannot be handled at all. This happens mostly for
   --                        operations that are possibly not supported such as Sync and Trim.
   type Result is (Success,
                   Retry,
                   Out_Of_Memory,
                   Unsupported);

   --  Create empty request
   --
   --  @return  empty, uninitialized request
   function Null_Request return Request with
      Post => Status (Null_Request'Result) = Raw;

   --  Get request type
   --
   --  @param R  Request
   --  @return   Request type
   function Kind (R : Request) return Request_Kind with
      Pre => Status (R) /= Raw;

   --  Get request status
   --
   --  @param R  Request
   --  @return   Request status
   function Status (R : Request) return Request_Status;

   --  Get request start block
   --
   --  @param R  Request
   --  @return   First block id to be handled by this request
   function Start (R : Request) return Id with
      Pre => Status (R) /= Raw;

   --  Get request length
   --
   --  @param R  Request
   --  @return   Number of consecutive blocks handled by this request
   function Length (R : Request) return Count with
      Pre => Status (R) /= Raw;

   --  Get request identifier
   --
   --  @param R  Request
   --  @return   Unique identifier of the request
   function Identifier (R : Request) return Request_Id with
      Pre => Status (R) /= Raw;

   --  Allocate request
   --
   --  This procedure allocates a request on the platform. This means setting the intended request range
   --  and identifier but also allocating the backing store for the block data. This procedure can fail,
   --  e.g. if not enough memory is available to allocate the block data store. In the case of success
   --  the request status will change from Raw to Allocated. In case of a failure it will stay Raw.
   --
   --  @param C  Client session instance
   --  @param R  Request to allocate
   --  @param K  Request type
   --  @param S  First block to be handled by the request
   --  @param L  Number of consecutive blocks to be handled
   --  @param I  Unique identifier for this request, chosen by the application
   --  @param E  Result of the allocation
   procedure Allocate_Request (C : in out Client_Session;
                               R : in out Request;
                               K :        Request_Kind;
                               S :        Id;
                               L :        Count;
                               I :        Request_Id;
                               E :    out Result) with
      Pre            => Initialized (C) and then Status (R) = Raw,
      Contract_Cases => (E = Success => Status (R) = Allocated,
                         others      => Status (R) = Raw);

   --  Checks if a request has been changed by the platform
   --
   --  @param C  Client session instance
   --  @param R  Request that shall be updated
   procedure Update_Request (C : in out Client_Session;
                             R : in out Request) with
      Pre  => Initialized (C)
              and Status (R) = Pending,
      Post => Initialized (C)
              and Status (R) in Pending | Ok | Error;

   --  Return True if C is initialized
   --
   --  @param C  Client session instance
   function Initialized (C : Client_Session) return Boolean;

   --  Create uninitialized client session
   --
   --  @return Uninitialized client session
   function Create return Client_Session with
      Post => not Initialized (Create'Result);

   --  Get the instance ID of C
   --
   --  @param C  Client session instance
   function Instance (C : Client_Session) return Client_Instance with
      Pre => Initialized (C);

   --  Initialize client instance
   --
   --  @param C            Client session instance
   --  @param Cap          System capability
   --  @param Path         Device id/path
   --  @param Buffer_Size  Platform buffer size
   --                      This is a hint for the platform how much space can be used for packet allocation.
   --                      The platform is free to decide if it follows this hint.
   --                      A value of 0 uses the platform default.
   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Componolit.Interfaces.Types.Capability;
                         Path        :        String;
                         Buffer_Size :        Byte_Length := 0) with
     Pre => not Initialized (C);

   --  Finalize client
   --
   --  @param C  client instance
   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

   --  Enqueue request
   --
   --  Enqueueing the request might fail. If this happens the request status will stay Allocated.
   --  If the request has been successfully enqueued it will be Pending.
   --
   --  @param C  Client session instance
   --  @param R  Request to enqueue
   procedure Enqueue (C : in out Client_Session;
                      R : in out Request) with
      Pre  => Initialized (C)
              and then Status (R) = Allocated,
      Post => Initialized (C)
              and Writable (C)'Old    = Writable (C)
              and Block_Count (C)'Old = Block_Count (C)
              and Block_Size (C)'Old  = Block_Size (C)
              and Status (R) in Allocated | Pending;

   --  Submit all enqueued requests for processing
   --
   --  @param C  Client session instance
   procedure Submit (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C)
              and Writable (C)'Old    = Writable (C)
              and Block_Count (C)'Old = Block_Count (C)
              and Block_Size (C)'Old  = Block_Size (C);

   --  Read the returned data from a successfully acknowledged read request
   --
   --  @param C  Client session instance
   --  @param R  Request to read data from
   procedure Read (C : in out Client_Session;
                   R :        Request) with
      Pre  => Initialized (C)
              and then Kind (R)   = Read
              and then Status (R) = Ok,
      Post => Initialized (C)
              and Writable (C)'Old    = Writable (C)
              and Block_Count (C)'Old = Block_Count (C)
              and Block_Size (C)'Old  = Block_Size (C);

   --  Release a request
   --
   --  If a request has been handled and is not needed anymore it needs to be released. This resets the
   --  request status to Raw and frees the resources aquired for this request on the platform.
   --  While only finished requests should be released it is possible to release unfinished requests
   --  as a measure to prevent resource leaks.
   --
   --  @param C  Client session instance
   --  @param R  Request to release
   procedure Release (C : in out Client_Session;
                      R : in out Request) with
      Pre  => Initialized (C)
              and then Status (R) /= Raw,
      Post => Initialized (C)
              and Writable (C)'Old    = Writable (C)
              and Block_Count (C)'Old = Block_Count (C)
              and Block_Size (C)'Old  = Block_Size (C)
              and Status (R)          = Raw;

   --  Check if the block device is writable
   --
   --  @param C  Client session instance
   function Writable (C : Client_Session) return Boolean with
      Pre => Initialized (C);

   --  Get the total number of blocks of the device
   --
   --  @param C  Client session instance
   function Block_Count (C : Client_Session) return Count with
      Pre => Initialized (C);

   --  Get the block size in bytes
   --
   --  @param C  Client session instance
   function Block_Size (C : Client_Session) return Size with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (C);

private

   type Request is new Componolit.Interfaces.Internal.Block.Client_Request;

end Componolit.Interfaces.Block.Client;
