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
pragma Warnings (Off, "procedure ""Event"" is not referenced");
pragma Warnings (Off, "procedure ""Read"" is not referenced");
pragma Warnings (Off, "procedure ""Write"" is not referenced");
--  Supress unreferenced warnings since not every platform needs this procedure

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
                        Bsize  : Size;
                        Start  : Id;
                        Length : Count;
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
                         Bsize  :     Size;
                         Start  :     Id;
                         Length :     Count;
                         Data   : out Buffer);
pragma Warnings (On, "procedure ""Event"" is not referenced");
pragma Warnings (On, "procedure ""Read"" is not referenced");
pragma Warnings (On, "procedure ""Write"" is not referenced");
package Componolit.Interfaces.Block.Client with
   SPARK_Mode
is

   pragma Unevaluated_Use_Of_Old (Allow);

   --  Block request
   --
   --  @field Kind    Request type
   --  @field Priv    Private platform data
   --  @field Start   First block to access
   --  @field Length  Number of consecutive blocks to access including the first block
   --  @field Status  Request status
   type Request (Kind : Request_Kind := None) is record
      Priv : Private_Data;
      case Kind is
         when None | Undefined =>
            null;
         when Read | Write | Sync | Trim =>
            Start  : Id;
            Length : Count;
            Status : Request_Status;
      end case;
   end record;

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

   --  Prove function to prove that the supported request types are not dependent on procedure calls
   --
   --  @param I  Client instance
   --  @param R  Request to check
   function Supported (I : Client_Instance;
                       R : Request_Kind) return Boolean with
      Ghost,
      Import;

   --  Checks if client supports handling the request (permanent property)
   --
   --  @param C  Client session instance
   --  @param R  Request to check
   function Supported (C : Client_Session;
                       R : Request_Kind) return Boolean with
      Annotate => (GNATprove, Terminating),
      Pre      => Initialized (C),
      Contract_Cases =>
         (R = None or R = Undefined => Supported'Result = False,
          others                    => Supported'Result = Supported (Get_Instance (C), R));

   --  Checks if client is ready to enqueue the request (temporary property)
   --
   --  @param C  Client session instance
   --  @param R  Request to check
   function Ready (C : Client_Session;
                   R : Request) return Boolean with
      Pre => Initialized (C) and then Supported (C, R.Kind);

   --  Get the next acknowledged request
   --
   --  The request is not removed from the queue and subsequent calls of this function have the same result.
   --  If no request is available Request.Kind is None.
   --
   --  @param C  Client session instance
   function Next (C : Client_Session) return Request with
      Pre  => Initialized (C),
      Post => (if Next'Result.Kind /= None and Next'Result.Kind /= Undefined
               then Next'Result.Status = Ok or Next'Result.Status = Error
               else True);

   --  Enqueue request
   --
   --  @param C  Client session instance
   --  @param R  Request to enqueue
   procedure Enqueue (C : in out Client_Session;
                      R :        Request) with
      Pre  => Initialized (C)
              and then R.Kind in Read | Write | Sync | Trim
              and then R.Status = Raw
              and then Supported (C, R.Kind)
              and then Ready (C, R),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximum_Transfer_Size (C)'Old = Maximum_Transfer_Size (C)
              and Next (C)'Old                  = Next (C)
              and (for all K in Request_Kind => Supported (Get_Instance (C)'Old, K) = Supported (Get_Instance (C), K));

   --  Submit all enqueued requests for processing
   --
   --  @param C  Client session instance
   procedure Submit (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximum_Transfer_Size (C)'Old = Maximum_Transfer_Size (C)
              and Next (C)'Old                  = Next (C)
              and (for all K in Request_Kind => Supported (Get_Instance (C)'Old, K) = Supported (Get_Instance (C), K));

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
              and Maximum_Transfer_Size (C)'Old = Maximum_Transfer_Size (C)
              and Next (C)'Old                  = Next (C)
              and (for all K in Request_Kind => Supported (Get_Instance (C)'Old, K) = Supported (Get_Instance (C), K));

   --  Release a request returned by Next
   --
   --  Removes the request from the queue.
   --  The next call of Next provides the next request in the queue or an invalid one if the queue is empty.
   --
   --  @param C  Client session instance
   --  @param R  Request to enqueue
   procedure Release (C : in out Client_Session;
                      R : in out Request) with
      Pre  => Initialized (C)
              and then (if R.Kind /= None and R.Kind /= Undefined then R.Status = Ok or R.Status = Error),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximum_Transfer_Size (C)'Old = Maximum_Transfer_Size (C)
              and (for all K in Request_Kind => Supported (Get_Instance (C)'Old, K) = Supported (Get_Instance (C), K));

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

end Componolit.Interfaces.Block.Client;
