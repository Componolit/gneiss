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

pragma Warnings (Off, "procedure ""Event"" is not referenced");
pragma Warnings (Off, "function ""Block_Count"" is not referenced");
pragma Warnings (Off, "function ""Block_Size"" is not referenced");
pragma Warnings (Off, "function ""Writable"" is not referenced");
pragma Warnings (Off, "function ""Maximal_Transfer_Size"" is not referenced");
pragma Warnings (Off, "procedure ""Initialize"" is not referenced");
pragma Warnings (Off, "procedure ""Finalize"" is not referenced");
--  Supress unreferenced warnings since not every platform needs each subprogram

generic
   --  Event handler, will be called received requests, ready queues, etc
   with procedure Event;
   --  Return the block count of the according session
   --
   --  @param S  Server session instance identifier
   with function Block_Count (S : Server_Instance) return Count;
   --  Return the block size of the according session in bytes
   --
   --  @param S  Server session instance identifier
   with function Block_Size (S : Server_Instance) return Size;
   --  Return if the according session is writable
   --
   --  @param S  Server session instance identifier
   with function Writable (S : Server_Instance) return Boolean;
   --  Return the maximal request size of the according session in bytes
   --
   --  @param S  Server session instance identifier
   with function Maximal_Transfer_Size (S : Server_Instance) return Byte_Length;
   --  Custom initialization for the server, automatically called by Cai.Block.Dispatcher.Session_Accept
   --
   --  @param S  Server session instance identifier
   --  @param L  Label passed by the client
   --  @param B  Internal buffer size as provided by the platform
   with procedure Initialize (S : Server_Instance;
                              L : String;
                              B : Byte_Length);
   --  Custom finalization for the server, automatically called by Cai.Block.Dispatcher.Session_Cleanup
   --  if the connected client disconnected
   --
   --  @param S  Server session instance identifier
   with procedure Finalize (S : Server_Instance);
package Cai.Block.Server with
   SPARK_Mode
is

   --  Redefinition of Cai.Block.Client.Request since SPARK does not allow discriminants of derived types
   --  SPARK RM 3.7 (2)
   --
   --  @field Kind    Request type
   --  @field Priv    Private platform data
   --  @field Start   First block to access
   --  @field Length  Number of consecutive blocks to access including the first block
   --  @field Status  Request status
   type Request (Kind : Request_Kind := None) is record
      Priv : Private_Data;
      case Kind is
         when None =>
            null;
         when Read .. Trim =>
            Start  : Id;
            Length : Count;
            Status : Request_Status;
      end case;
   end record;

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
   function Get_Instance (S : Server_Session) return Server_Instance with
      Pre => Initialized (S);

   --  Get the next request that is pending for consumption,
   --  will not remove the request from the queue
   --  Request.Kind is None if no request is available
   --
   --  @param S  Server session instance
   function Head (S : Server_Session) return Request with
      Pre => Initialized (S);

   --  Discars the request currently available from Head making the next one available
   --
   --  @param S  Server session instance
   procedure Discard (S : in out Server_Session) with
      Pre  => Initialized (S),
      Post => Initialized (S);

   --  Provide the requested data for a read request
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param B  Buffer with read data
   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer) with
      Pre  => Initialized (S)
              and R.Kind = Read
              and B'Length = R.Length * Block_Size (Get_Instance (S)),
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
              and R.Kind = Write
              and B'Length = R.Length * Block_Size (Get_Instance (S)),
      Post => Initialized (S);

   --  Acknowledge a handled request
   --
   --  @param S  Server session instance
   --  @param R  Request to acknowledge
   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request) with
      Pre  => Initialized (S) and (R.Status = Ok or R.Status = Error),
      Post => Initialized (S);

   --  Signal client to wake up
   --
   --  @param S  Server session instance
   procedure Unblock_Client (S : in out Server_Session);

end Cai.Block.Server;
