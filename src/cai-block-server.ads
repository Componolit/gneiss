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
   with procedure Event;
   --  Event handler, will be called received requests, ready queues, etc
   with function Block_Count (S : Server_Instance) return Count;
   --  Return the block count of the according session
   --
   --  @param S  Server session instance identifier
   with function Block_Size (S : Server_Instance) return Size;
   --  Return the block size of the according session in bytes
   --
   --  @param S  Server session instance identifier
   with function Writable (S : Server_Instance) return Boolean;
   --  Return if the according session is writable
   --
   --  @param S  Server session instance identifier
   with function Maximal_Transfer_Size (S : Server_Instance) return Byte_Length;
   --  Return the maximal request size of the according session in bytes
   --
   --  @param S  Server session instance identifier
   with procedure Initialize (S : Server_Instance;
                              L : String);
   --  Custom initialization for the server, automatically called by Cai.Block.Dispatcher.Session_Accept
   --
   --  @param S  Server session instance identifier
   --  @param L  Label provided by the dispatcher
   with procedure Finalize (S : Server_Instance);
   --  Custom finalization for the server, automatically called by Cai.Block.Dispatcher.Session_Cleanup
   --  if the connected client disconnected
   --
   --  @param S  Server session instance identifier
package Cai.Block.Server with
   SPARK_Mode
is

   --  Redefinition of Cai.Block.Client.Request since SPARK does not allow discriminants of derived types
   --  SPARK RM 3.7 (2)
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

   function Initialized (S : Server_Session) return Boolean;
   --  Check if S is initialized
   --
   --  @param S  Server session instance

   function Create return Server_Session with
      Post => not Initialized (Create'Result);

   function Get_Instance (S : Server_Session) return Server_Instance with
      Pre => Initialized (S);
   --  Get the instance ID of S
   --
   --  @param S  Server session instance

   function Head (S : Server_Session) return Request with
      Pre => Initialized (S);
   --  Get the next request that is pending for consumption,
   --  will not remove the request from the queue
   --  Request.Kind is None if no request is available
   --
   --  @param S  Server session instance

   procedure Discard (S : in out Server_Session) with
      Pre  => Initialized (S),
      Post => Initialized (S);
   --  Discars the request currently available from Head making the next one available
   --
   --  @param S  Server session instance

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer) with
      Pre  => Initialized (S)
              and R.Kind = Read
              and B'Length = R.Length * Block_Size (Get_Instance (S)),
      Post => Initialized (S);
   --  Provide the requested data for a read request
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param B  Buffer with read data

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer) with
      Pre  => Initialized (S)
              and R.Kind = Write
              and B'Length = R.Length * Block_Size (Get_Instance (S)),
      Post => Initialized (S);
   --  Get the data of a write request that shall be written
   --
   --  @param S  Server session instance
   --  @param R  Request to handle
   --  @param B  Buffer with data to be written after

   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request) with
      Pre  => Initialized (S) and (R.Status = Ok or R.Status = Error),
      Post => Initialized (S);
   --  Acknowledge a handled request
   --
   --  @param S  Server session instance
   --  @param R  Request to acknowledge

end Cai.Block.Server;
