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
pragma Warnings (Off, "procedure ""Event"" is not referenced");
pragma Warnings (Off, "procedure ""Read"" is not referenced");
pragma Warnings (Off, "procedure ""Write"" is not referenced");
--  Supress unreferenced warnings since not every platform needs this procedure

   --  max 32bit request identifier
   type Request_Id is (<>);

   --  Block client event handler
   with procedure Event;

   --  Called when a read has been triggered and data is available
   --  Pre => Data'Length = Bsize * Length
   --
   --  @param C       Client session instance identifier
   --  @param Bsize   Block size of C
   --  @param Start   Start block that has been read from
   --  @param Length  Number of blocks to read
   --  @param Data    Read data
   with procedure Read (C      : Client_Instance;
                        Req    : Request_Id;
                        Data   : Buffer);

   --  Write procedure called when the platform required data to write
   --  Pre => Data'Length = Bsize * Length
   --
   --  @param C       Client session instance identifier
   --  @param Bsize   Block size of C
   --  @param Start   Start block that is written to
   --  @param Length  Number of blocks that will be written
   --  @param Data    Data that will be written
   with procedure Write (C      :     Client_Instance;
                         Req    :     Request_Id;
                         Data   : out Buffer);
pragma Warnings (On, "procedure ""Event"" is not referenced");
pragma Warnings (On, "procedure ""Read"" is not referenced");
pragma Warnings (On, "procedure ""Write"" is not referenced");
package Componolit.Interfaces.Block.Client with
   SPARK_Mode
is

   --  Block client request
   type Request is limited private;

   --  Request capability, holds unevaluated meta data of an incoming request response
   type Request_Capability is private;

   --  Create empty request
   --
   --  @return  empty, uninitialized request
   function Create_Request return Request with
      Post => Request_State (Create_Request'Result) = Raw;

   --  Get request type
   --
   --  @param R  Request
   --  @return   Request type
   function Request_Type (R : Request) return Request_Kind with
      Pre => Request_State (R) /= Raw;

   --  Get request status
   --
   --  @param R  Request
   --  @return   Request status
   function Request_State (R : Request) return Request_Status;

   --  Get request start block
   --
   --  @param R  Request
   --  @return   First block id to be handled by this request
   function Request_Start (R : Request) return Id with
      Pre => Request_State (R) /= Raw;

   --  Get request length
   --
   --  @param R  Request
   --  @return   Number of consecutive blocks handled by this request
   function Request_Length (R : Request) return Count with
      Pre => Request_State (R) /= Raw;

   --  Get request identifier
   --
   --  @param R  Request
   --  @return   Unique identifier of the request
   function Request_Identifier (R : Request) return Request_Id with
      Pre => Request_State (R) /= Raw;

   --  Allocate request
   --
   --  This procedure allocates a request on the platform. This means setting the intended request range
   --  and identifier but also allocating the backing store for the block data. This procedure can fail,
   --  e.g. if not enough memory is available to allocate the block data store. In the case of success
   --  the request status will change from Raw to Allocated. In case of a failure it will stay Raw.
   --
   --  @param C       Client session instance
   --  @param R       Request to allocate
   --  @param Kind    Request type
   --  @param Start   First block to be handled by the request
   --  @param Length  Number of consecutive blocks to be handled
   --  @param Ident   Unique identifier for this request, chosen by the application
   procedure Allocate_Request (C      : in out Client_Session;
                               R      : in out Request;
                               Kind   :        Request_Kind;
                               Start  :        Id;
                               Length :        Count;
                               Ident  :        Request_Id) with
      Pre => Initialized (C) and then Request_State (R) = Raw;

   --  Check if the request capability is valid
   --
   --  @param C  Request capability
   --  @return   True if capability is valid
   function Valid_Capability (C : Request_Capability) return Boolean;

   --  Get the request identifier linked with the capability
   --
   --  @param C  Request capability
   --  @return   Identifier of the request linked to this capability
   function Request_Identifier (C : Request_Capability) return Request_Id with
      Pre => Valid_Capability (C);

   --  Check the response queue for updates
   --
   --  Reads the first element from the response queue and saves its meta data into the request capability.
   --  The capability is required to update a request with the according metadata.
   procedure Update_Response_Queue (C     : in out Client_Session;
                                    R_Cap :    out Request_Capability) with
      Pre => Initialized (C);

   procedure Update_Request (C     : in out Client_Session;
                             R     : in out Request;
                             R_Cap :        Request_Capability) with
      Pre => Initialized (C)
             and then Valid_Capability (R_Cap)
             and then Request_Identifier (R) = Request_Identifier (R_Cap);

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
   function Get_Instance (C : Client_Session) return Client_Instance with
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
   --  @param C  Client session instance
   --  @param R  Request to enqueue
   procedure Enqueue (C : in out Client_Session;
                      R : in out Request) with
      Pre  => Initialized (C)
              and then Request_State (R) = Allocated,
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximum_Transfer_Size (C)'Old = Maximum_Transfer_Size (C)
              and Request_State (R)             = Pending;

   --  Submit all enqueued requests for processing
   --
   --  @param C  Client session instance
   procedure Submit (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximum_Transfer_Size (C)'Old = Maximum_Transfer_Size (C);

   --  Read the returned data from a successfully acknowledged read request
   --
   --  @param C  Client session instance
   --  @param R  Request to read data from
   procedure Read (C : in out Client_Session;
                   R :        Request) with
      Pre  => Initialized (C)
              and then Request_Type (R) = Read
              and then Request_State (R) = Ok,
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximum_Transfer_Size (C)'Old = Maximum_Transfer_Size (C);

   --  Release a request
   --
   --  If a request has been handled and is not needed anymore it needs to be release. This resets the
   --  request status to Raw and frees the resources aquired for this request on the platform.
   --  While only finished requests should be released it is possible to release unfinished requests
   --  as a measure to prevent resource leaks.
   --
   --  @param C  Client session instance
   --  @param R  Request to release
   procedure Release (C : in out Client_Session;
                      R : in out Request) with
      Pre  => Initialized (C)
              and then Request_State (R) /= Raw,
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximum_Transfer_Size (C)'Old = Maximum_Transfer_Size (C)
              and Request_State (R)             = Raw;

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

   --  Get the maximum number of bytes for a single request
   --
   --  @param C  Client session instance
   function Maximum_Transfer_Size (C : Client_Session) return Byte_Length with
      Pre => Initialized (C);

private

   type Request is new Componolit.Interfaces.Internal.Block.Client_Request;
   type Request_Capability is new Componolit.Interfaces.Internal.Block.Client_Request_Capability;

end Componolit.Interfaces.Block.Client;
