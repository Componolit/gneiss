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

generic
   pragma Warnings (Off, "* is not referenced");
   --  Supress unreferenced warnings since not every platform needs each subprogram

   --  Event handler, is called on received requests, ready queues, etc.
   with procedure Event;

   --  Return the block count of session S
   --
   --  @param S  Server session instance identifier
   --  @return   Number of blocks on the device
   with function Block_Count (S : Server_Instance) return Count;

   --  Return the block size of session S in bytes
   --
   --  @param S  Server session instance identifier
   --  @return   Size of a block
   with function Block_Size (S : Server_Instance) return Size;

   --  Return if session S is writable
   --
   --  @param S  Server session instance identifier
   --  @return   True if the device can be written
   with function Writable (S : Server_Instance) return Boolean;

   --  Checks if the server is initialized
   --
   --  @param S  Server session instance identifier
   --  @return   True if the server is initialized
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

   pragma Warnings (On, "* is not referenced");
package Componolit.Interfaces.Block.Server with
   SPARK_Mode
is

   --  Process an incoming request
   --
   --  A raw request can be used to process an incoming request. If the request is Pending after this procedure
   --  call it holds a request that needs to be handled. If it is still raw there is nothing to handle.
   --
   --  @param S  Server session instance
   --  @param R  Raw request slot
   procedure Process (S : in out Server_Session;
                      R : in out Server_Request) with
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
                   R :        Server_Request;
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
                    R :        Server_Request;
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
   procedure Acknowledge (S   : in out Server_Session;
                          R   : in out Server_Request;
                          Res :        Request_Status) with
      Pre  => Initialized (S)
              and then Status (R) = Pending
              and then Res in Ok | Error,
      Post => Initialized (S)
              and then Status (R) in Raw | Pending;

   --  Signal client to wake up
   --
   --  Some platforms do not wake up the client if the server returns unless explicitly being told to.
   --  If this procedure is not called at least once before returning from the event handler a deadlock might occur.
   --
   --  @param S  Server session instance
   procedure Unblock_Client (S : in out Server_Session) with
      Pre  => Initialized (S),
      Post => Initialized (S);

end Componolit.Interfaces.Block.Server;
