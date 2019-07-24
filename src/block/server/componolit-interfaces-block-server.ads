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

private with Componolit.Interfaces.Internal.Block;

pragma Warnings (Off, "procedure ""Event"" is not referenced");
pragma Warnings (Off, "function ""Block_Count"" is not referenced");
pragma Warnings (Off, "function ""Block_Size"" is not referenced");
pragma Warnings (Off, "function ""Writable"" is not referenced");
pragma Warnings (Off, "function ""Maximum_Transfer_Size"" is not referenced");
pragma Warnings (Off, "procedure ""Initialize"" is not referenced");
pragma Warnings (Off, "procedure ""Finalize"" is not referenced");
--  Supress unreferenced warnings since not every platform needs each subprogram

generic
   --  Event handler, is called on received requests, ready queues, etc.
   with procedure Event;

   --  Return the block count of session S
   --
   --  @param S  Server session instance identifier
   with function Block_Count (S : Server_Instance) return Count;

   --  Return the block size of session S in bytes
   --
   --  @param S  Server session instance identifier
   with function Block_Size (S : Server_Instance) return Size;

   --  Return if session S is writable
   --
   --  @param S  Server session instance identifier
   with function Writable (S : Server_Instance) return Boolean;

   --  Return the maximum request size of session S in bytes
   --
   --  @param S  Server session instance identifier
   with function Maximum_Transfer_Size (S : Server_Instance) return Byte_Length;

   with function Initialized (S : Server_Instance) return Boolean;

   --  Custom initialization for the server,
   --  automatically called by Componolit.Interfaces.Block.Dispatcher.Session_Accept
   --
   --  @param S  Server session instance identifier
   --  @param L  Label passed by the client
   --  @param B  Internal buffer size as provided by the platform
   with procedure Initialize (S : Server_Instance;
                              L : String;
                              B : Byte_Length);

   --  Custom finalization for the server
   --
   --  Is automatically called by Componolit.Interfaces.Block.Dispatcher.Session_Cleanup
   --  when the connected client disconnects.
   --
   --  @param S  Server session instance identifier
   with procedure Finalize (S : Server_Instance);
package Componolit.Interfaces.Block.Server with
   SPARK_Mode
is

   --  Block server request
   type Request is limited private;

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
      Pre => Status (R) = Pending;

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
      Pre => Status (R) = Pending;

   --  Get request length in blocks
   --
   --  @param R  Request
   --  @return   Number of consecutive blocks handled by this request
   function Length (R : Request) return Count with
      Pre => Status (R) = Pending;

   --  Check if S is initialized
   --
   --  @param S  Server session instance
   function Initialized (S : Server_Session) return Boolean;

   --  Create new server session
   --
   --  @return Uninitialized server session
   function Create return Server_Session with
      Post => not Initialized (Create'Result);

   --  Get the instance ID of S
   --
   --  @param S  Server session instance
   function Instance (S : Server_Session) return Server_Instance with
      Pre => Initialized (S);

   --  Process an incoming request
   --
   --  A raw request can be used to process an incoming request. If the request is Pending after this procedure
   --  call it holds a request that needs to be handled. If it is still raw there is nothing to handle.
   --
   --  @param S  Server session instance
   --  @param R  Raw request slot
   procedure Process (S : in out Server_Session;
                      R : in out Request) with
      Pre  => Initialized (S)
              and then Status (R) = Raw,
      Post => Initialized (S)
              and then Status (R) in Raw | Pending;

   --  Provide the requested data for a read request
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param B  Buffer with read data
   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer) with
      Pre  => Initialized (S)
              and then Status (R) = Pending
              and then Kind (R) = Read
              and then B'Length = Length (R) * Block_Size (Instance (S)),
      Post => Initialized (S);

   --  Get the data of a write request that shall be written
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param B  Buffer with data to be written after
   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer) with
      Pre  => Initialized (S)
              and then Status (R) = Pending
              and then Kind (R) = Write
              and then B'Length = Length (R) * Block_Size (Instance (S)),
      Post => Initialized (S);

   --  Acknowledge a handled request
   --
   --  If the request type is Raw after this procedure call, the request has been acknowledged successfully,
   --  if not the acknowledgement has failed and needs to be retried.
   --
   --  @param S  Server session instance
   --  @param R  Request to acknowledge
   procedure Acknowledge (S      : in out Server_Session;
                          R      : in out Request;
                          Result :        Request_Status) with
      Pre  => Initialized (S)
              and then Status (R) = Pending
              and then Result in Ok | Error,
      Post => Initialized (S)
              and then Status (R) in Raw | Pending;

   --  Signal client to wake up
   --
   --  Some platforms do not wake up the client if the server returns unless explicitly being told to.
   --  If this procedure is not called at least once before returning from the event handler a deadlock might occur.
   --
   --  @param S  Server session instance
   procedure Unblock_Client (S : in out Server_Session);

private

   type Request is new Componolit.Interfaces.Internal.Block.Server_Request;

end Componolit.Interfaces.Block.Server;
