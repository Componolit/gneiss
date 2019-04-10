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

with Cai.Types;

pragma Warnings (Off, "procedure ""Event"" is not referenced");
--  Supress unreferenced warnings since not every platform needs this procedure

generic
   --  Callback on events
   with procedure Event;
   --  Called when a read has been triggered and data is available
   --  Pre => Data'Length = Bsize * Length
   --
   --  C       Client session instance identifier
   --  Bsize   Block size of C
   --  Start   Start block that has been read from
   --  Length  number of blocks to read
   --  Data    Read data
   with procedure Read (C      : Client_Instance;
                        Bsize  : Size;
                        Start  : Id;
                        Length : Count;
                        Data   : Buffer);
   --  Write procedure called when the platform required data to write
   --  Pre => Data'Length = Bsize * Length
   --
   --  C       Client session instance identifier
   --  Bsize   Block size of C
   --  Start   Start block that is written to
   --  Length  number of blocks that will be written
   --  Data    Data that will be written
   with procedure Write (C      :     Client_Instance;
                         Bsize  :     Size;
                         Start  :     Id;
                         Length :     Count;
                         Data   : out Buffer);
package Cai.Block.Client with
   SPARK_Mode
is

   type Request (Kind : Request_Kind := None) is record
      Priv : Private_Data;           --  Platform specific data
      case Kind is
         when None =>
            null;
         when Read .. Trim =>
            Start  : Id;             --  First block to access
            Length : Count;          --  Number of block to access including the first block
            Status : Request_Status; --  Request status
      end case;
   end record;
   --  Block request
   --
   --  @param Kind  request type

   function Initialized (C : Client_Session) return Boolean;
   --  Return True if C is initialized
   --
   --  @param C  Client session instance

   function Create return Client_Session with
      Post => not Initialized (Create'Result);

   function Get_Instance (C : Client_Session) return Client_Instance with
      Pre => Initialized (C);
   --  Get the instance ID of C
   --
   --  @param C  Client session instance

   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Cai.Types.Capability;
                         Path        :        String;
                         Buffer_Size :        Byte_Length := 0);
   --  Initialize client instance
   --
   --  @param C            Client session instance
   --  @param Cap          System capability
   --  @param Path         Device id/path
   --  @param Buffer_Size  platform buffer size, may determine maximal transfer size

   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);
   --  Finalize client
   --
   --  @param C  client instance

   function Ready (C : Client_Session;
                   R : Request) return Boolean with
      Pre => Initialized (C);
   --  Checks if client is ready to enqueue the request (temporary property)
   --
   --  @param C  Client session instance
   --  @param R  Request to check

   function Supported (C : Client_Session;
                       R : Request_Kind) return Boolean with
      Pre => Initialized (C) and then Supported (C, R);

   --  Enqueue request
   --
   --  @param C  Client session instance
   --  @param R  Request to enqueue
   procedure Enqueue (C : in out Client_Session;
                      R :        Request) with
      Pre  => Initialized (C)
              and then R.Kind in Read .. Trim
              and then R.Status = Raw
              and then Supported (C, R.Kind)
              and then Ready (C, R),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximal_Transfer_Size (C)'Old = Maximal_Transfer_Size (C);
   --  Enqueue trim request
   --
   --  @param C  Client session instance
   --  @param R  Request to enqueue

   procedure Submit (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximal_Transfer_Size (C)'Old = Maximal_Transfer_Size (C);
   --  Submit all enqueued requests for processing
   --
   --  @param C  Client session instance

   function Next (C : Client_Session) return Request with
      Volatile_Function,
      Pre  => Initialized (C),
      Post => (if Next'Result.Kind /= None
               then Next'Result.Status = Ok or Next'Result.Status = Error
               else True);
   --  Get the next acknowledged request
   --  The request will not be removed from the queue and subsequent calls of this function
   --  will have the same result
   --  If no request is available Request.Kind is None
   --
   --  @param C  Client session instance

   --  Read the returned data from a successfully acknowledged read request
   --
   --  @param C  Client session instance
   --  @param R  Request to read data from
   procedure Read (C : in out Client_Session;
                   R :        Request) with
      Pre  => Initialized (C)
              and then R.Kind = Read
              and then R.Status = Ok,
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximal_Transfer_Size (C)'Old = Maximal_Transfer_Size (C);
   --  Read the returned data from a successfully acknowledged read request
   --
   --  @param C  Client session instance
   --  @param R  Request to read data from
   --  @param B  Buffer to read data into

   procedure Release (C : in out Client_Session;
                      R : in out Request) with
      Pre  => Initialized (C)
              and then R.Kind /= None
              and then (R.Status = Ok or R.Status = Error),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximal_Transfer_Size (C)'Old = Maximal_Transfer_Size (C);
   --  Release a request returned by Next,
   --  this will remove the request from the queue and Next will provide a new request
   --
   --  @param C  Client session instance
   --  @param R  Request to enqueue

   function Writable (C : Client_Session) return Boolean with
      Pre => Initialized (C);
   --  Check if the block device is writable
   --
   --  @param C  Client session instance

   function Block_Count (C : Client_Session) return Count with
      Pre => Initialized (C);
   --  Get the total number of blocks of the device
   --
   --  @param C  Client session instance

   function Block_Size (C : Client_Session) return Size with
      Pre => Initialized (C);
   --  Get the block size in bytes
   --
   --  @param C  Client session instance

   function Maximal_Transfer_Size (C : Client_Session) return Byte_Length with
      Pre => Initialized (C);
   --  Get the maximal number of bytes for a single request
   --
   --  @param C  Client session instance

end Cai.Block.Client;
