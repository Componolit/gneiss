--
--  @summary Block server interface
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Componolit.Gneiss.Internal.Block;

generic
   pragma Warnings (Off, "* is not referenced");
   --  Supress unreferenced warnings since not every platform needs each subprogram

   --  Event handler, is called on received requests, ready queues, etc.
   with procedure Event;

   --  Return the block count of session S
   --
   --  @param S  Server session instance identifier
   --  @return   Number of blocks on the device
   with function Block_Count (S : Server_Session) return Count;

   --  Return the block size of session S in bytes
   --
   --  @param S  Server session instance identifier
   --  @return   Size of a block
   with function Block_Size (S : Server_Session) return Size;

   --  Return if session S is writable
   --
   --  @param S  Server session instance identifier
   --  @return   True if the device can be written
   with function Writable (S : Server_Session) return Boolean;

   --  Checks if the server implementation is ready
   --
   --  @param S  Server session instance identifier
   --  @return   True if the server implementation is ready
   with function Ready (S : Server_Session) return Boolean;

   --  Custom initialization for the server,
   --  automatically called by Componolit.Gneiss.Block.Dispatcher.Session_Accept
   --
   --  @param S  Server session instance identifier
   --  @param L  Label passed by the client
   --  @param B  Internal buffer size as provided by the platform
   with procedure Initialize (S : in out Server_Session;
                              L :        String;
                              B :        Byte_Length);

   --  Custom finalization for the server
   --
   --  Is automatically called by Componolit.Gneiss.Block.Dispatcher.Session_Cleanup
   --  when the connected client disconnects.
   --
   --  @param S  Server session instance identifier
   with procedure Finalize (S : in out Server_Session);

   --  Called when a read has been triggered and data to read is needed
   --
   --  The length of Data always corresponds to the request length in bytes (block size * block count)
   --
   --  @param S       Server session instance
   --  @param Req     Request identifier of request to write
   --  @param Data    Data to read
   with procedure Read (S    : in out Server_Session;
                        Req  :        Request_Id;
                        Data :    out Buffer);

   --  Called when a write has been triggered and data to write is available
   --
   --  The length of Data always corresponds to the request length in bytes (block size * block count)
   --
   --  @param S       Server session instance
   --  @param Req     Request identifier of request to write
   --  @param Data    Data to write
   with procedure Write (S    : in out Server_Session;
                         Req  :        Request_Id;
                         Data :        Buffer);
   pragma Warnings (On, "* is not referenced");
package Componolit.Gneiss.Block.Server with
   SPARK_Mode
is

   pragma Unevaluated_Use_Of_Old (Allow);

   --  Block server request
   type Request is limited private;

   --  Get request status
   --
   --  @param R  Request
   --  @return   Request status
   function Status (R : Request) return Request_Status with
      Annotate => (GNATprove, Terminating);

   --  Get request type
   --
   --  @param R  Request
   --  @return   Request type
   function Kind (R : Request) return Request_Kind with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) = Pending;

   --  Get request start block
   --
   --  @param R  Request
   --  @return   First block id to be handled by this request
   function Start (R : Request) return Id with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) = Pending;

   --  Get request length in blocks
   --
   --  @param R  Request
   --  @return   Number of consecutive blocks handled by this request
   function Length (R : Request) return Count with
      Annotate => (GNATprove, Terminating),
      Pre => Status (R) = Pending;

   --  Check if a request is assigned to this session
   --
   --  When a request is allocated it gets assigned to the session that is used for allocation.
   --  It can then only be used by this session.
   --
   --  @param S  Server session instance
   --  @param R  Request to check
   --  @return   True if the R is assigned to S
   function Assigned (S : Server_Session;
                      R : Request) return Boolean with
      Annotate => (GNATprove, Terminating),
      Pre => Initialized (S)
             and then Status (R) /= Raw;

   --  Process an incoming request
   --
   --  A raw request can be used to process an incoming request. If the request is Pending after this procedure
   --  call it holds a request that needs to be handled. If it is still raw there is nothing to handle.
   --
   --  @param S  Server session instance
   --  @param R  Raw request slot
   procedure Process (S : in out Server_Session;
                      R : in out Request) with
      Pre  => Ready (S)
              and then Initialized (S)
              and then Status (R) = Raw,
      Post => Ready (S)
              and then Initialized (S)
              and then Status (R) in Raw | Pending | Error
              and then (if Status (R) in Pending | Error then Assigned (S, R));

   --  Provide the requested data for a read request
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param B  Buffer with read data
   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer) with
      Pre  => Ready (S)
              and then Initialized (S)
              and then Status (R) = Pending
              and then Kind (R)   = Read
              and then B'Length   = Length (R) * Block_Size (S)
              and then Assigned (S, R),
      Post => Ready (S)
              and then Initialized (S)
              and then Assigned (S, R);

   --  Call Read callback to provide data to read
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param I  Application defined identifier of the request
   procedure Read (S : in out Server_Session;
                   R :        Request;
                   I :        Request_Id) with
      Pre  => Ready (S)
              and then Initialized (S)
              and then Status (R) = Pending
              and then Kind (R)   = Read
              and then Assigned (S, R),
      Post => Ready (S)
              and then Initialized (S)
              and then Assigned (S, R);

   --  Get the data of a write request that shall be written
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param B  Buffer with data to be written after
   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer) with
      Pre  => Ready (S)
              and then Initialized (S)
              and then Status (R) = Pending
              and then Kind (R)   = Write
              and then B'Length   = Length (R) * Block_Size (S)
              and then Assigned (S, R),
      Post => Ready (S)
              and then Initialized (S)
              and then Assigned (S, R);

   --  Call Write callback to provide data to write
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param I  Application defined identifier of the request
   procedure Write (S : in out Server_Session;
                    R :        Request;
                    I :        Request_Id) with
      Pre  => Ready (S)
              and then Initialized (S)
              and then Status (R) = Pending
              and then Kind (R)   = Write
              and then Assigned (S, R),
      Post => Ready (S)
              and then Initialized (S)
              and then Assigned (S, R);

   --  Acknowledge a handled request
   --
   --  If the request type is Raw after this procedure call, the request has been acknowledged successfully,
   --  if not the acknowledgement has failed and needs to be retried.
   --
   --  @param S  Server session instance
   --  @param R  Request to acknowledge
   procedure Acknowledge (S   : in out Server_Session;
                          R   : in out Request;
                          Res :        Request_Status) with
      Pre  => Ready (S)
              and then Initialized (S)
              and then ((Status (R) = Pending and then Res in Ok | Error)
                        or else (Status (R) = Error and then Res = Error))
              and then Assigned (S, R),
      Post => Ready (S)
              and then Initialized (S)
              and then Status (R) in Raw | Pending | Error
              and then (if Status (R) in Pending | Error then Assigned (S, R));

   --  Signal client to wake up
   --
   --  Some platforms do not wake up the client if the server returns unless explicitly being told to.
   --  If this procedure is not called at least once before returning from the event handler a deadlock might occur.
   --
   --  @param S  Server session instance
   procedure Unblock_Client (S : in out Server_Session) with
      Pre  => Initialized (S),
      Post => Initialized (S)
              and then Ready (S)'Old = Ready (S);

private

   type Request is new Componolit.Gneiss.Internal.Block.Server_Request;

   function Lemma_Ready (S : Server_Session) return Boolean is
      (Ready (S)) with
      Pre => Valid (S);

   --  Return the block count of session S
   --
   --  @param S  Server session instance identifier
   --  @return   Number of blocks on the device
   function Lemma_Block_Count (S : Server_Session) return Count is
      (Block_Count (S)) with
         Ghost,
         Pre => Ready (S);

   --  Return the block size of session S in bytes
   --
   --  @param S  Server session instance identifier
   --  @return   Size of a block
   function Lemma_Block_Size (S : Server_Session) return Size is
      (Block_Size (S)) with
         Ghost,
         Pre => Ready (S);

   --  Return if session S is writable
   --
   --  @param S  Server session instance identifier
   --  @return   True if the device can be written
   function Lemma_Writable (S : Server_Session) return Boolean is
      (Writable (S)) with
         Ghost,
         Pre => Ready (S);

   --  Custom initialization for the server,
   --  automatically called by Componolit.Gneiss.Block.Dispatcher.Session_Accept
   --
   --  @param S  Server session instance identifier
   --  @param L  Label passed by the client
   --  @param B  Internal buffer size as provided by the platform
   procedure Lemma_Initialize (S : in out Server_Session;
                               L :        String;
                               B :        Byte_Length) with
      Ghost,
      Pre => Valid (S)
             and then not Ready (S);

   pragma Annotate (GNATprove, False_Positive,
                    "ghost procedure ""Lemma_Initialize"" cannot have non-ghost global output *",
                    "This procedure is only used to enforce the precondition of Dispatch");

   --  Custom finalization for the server
   --
   --  Is automatically called by Componolit.Gneiss.Block.Dispatcher.Session_Cleanup
   --  when the connected client disconnects.
   --
   --  @param S  Server session instance identifier
   procedure Lemma_Finalize (S : in out Server_Session) with
      Ghost,
      Pre => Ready (S);

   pragma Annotate (GNATprove, False_Positive,
                    "ghost procedure ""Lemma_Finalize"" cannot have non-ghost global output *",
                    "This procedure is only used to enforce the precondition of Dispatch");

end Componolit.Gneiss.Block.Server;
