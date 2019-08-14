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

generic
   pragma Warnings (Off, "* is not referenced");
   --  Supress unreferenced warnings since not every platform needs this procedure

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
                               R : in out Client_Request;
                               K :        Request_Kind;
                               S :        Id;
                               L :        Count;
                               I :        Request_Id;
                               E :    out Result) with
      Pre  => Initialized (C)
              and Status (R) = Raw,
      Post => Initialized (C)
              and Writable (C)'Old    = Writable (C)
              and Block_Count (C)'Old = Block_Count (C)
              and Block_Size (C)'Old  = Block_Size (C)
              and (if E = Success then Status (R) = Allocated else Status (R) = Raw);

   --  Checks if a request has been changed by the platform
   --
   --  @param C  Client session instance
   --  @param R  Request that shall be updated
   procedure Update_Request (C : in out Client_Session;
                             R : in out Client_Request) with
      Pre  => Initialized (C)
              and Status (R) = Pending,
      Post => Initialized (C)
              and Status (R) in Pending | Ok | Error
              and Writable (C)'Old    = Writable (C)
              and Block_Count (C)'Old = Block_Count (C)
              and Block_Size (C)'Old  = Block_Size (C);

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
                      R : in out Client_Request) with
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
                   R :        Client_Request) with
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
                      R : in out Client_Request) with
      Pre  => Initialized (C)
              and then Status (R) /= Raw,
      Post => Initialized (C)
              and Writable (C)'Old    = Writable (C)
              and Block_Count (C)'Old = Block_Count (C)
              and Block_Size (C)'Old  = Block_Size (C)
              and Status (R)          = Raw;

private

   --  Called when a read has been triggered and data is available
   --
   --  The length of Data always corresponds to the request length in bytes (block size * block count)
   --
   --  @param C       Client session instance identifier
   --  @param Req     Request identifier of request to write
   --  @param Data    Read data
   procedure Lemma_Read (C      : Client_Instance;
                         Req    : Request_Id;
                         Data   : Buffer) with
      Ghost,
      Pre => Initialized (C);

   pragma Annotate (GNATprove, False_Positive,
                    "ghost procedure ""Lemma_Read"" cannot have non-ghost global output*",
                    "This procedure is only used to enforce the precondition of Dispatch");

   --  Write procedure called when the platform required data to write
   --
   --  The length of Data always corresponds to the request length in bytes (block size * block count)
   --
   --  @param C       Client session instance identifier
   --  @param Req     Request identifier of request to write
   --  @param Data    Data that will be written
   procedure Lemma_Write (C      :     Client_Instance;
                          Req    :     Request_Id;
                          Data   : out Buffer) with
      Ghost,
      Pre => Initialized (C);

   pragma Annotate (GNATprove, False_Positive,
                    "ghost procedure ""Lemma_Write"" cannot have non-ghost global output*",
                    "This procedure is only used to enforce the precondition of Dispatch");

end Componolit.Interfaces.Block.Client;
