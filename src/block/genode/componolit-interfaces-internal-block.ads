
with System;
with Cxx;
with Cxx.Block.Client;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;

package Componolit.Interfaces.Internal.Block is

   type Private_Data is new Cxx.Genode_Uint8_T_Array (1 .. 16);
   Null_Data : Private_Data := (others => 0);

   type Request_Status is (Raw, Allocated, Pending, Ok, Error);

   type Client_Request is limited record
      Packet : Cxx.Block.Client.Packet_Descriptor;
      Status : Request_Status;
   end record;

   type Client_Request_Handle is record
      Valid   : Boolean;
      Tag     : Cxx.Unsigned_Long;
      Success : Boolean;
   end record;

   type Server_Request is limited record
      Request : Cxx.Block.Server.Request;
      Status  : Request_Status;
   end record;

   type Client_Session is limited record
      Instance : Cxx.Block.Client.Class;
   end record;
   type Dispatcher_Session is limited record
      Instance : Cxx.Block.Dispatcher.Class;
   end record;
   type Server_Session is limited record
      Instance : Cxx.Block.Server.Class;
   end record;
   type Client_Instance is new System.Address;
   type Dispatcher_Instance is new System.Address;
   type Server_Instance is new System.Address;
   type Dispatcher_Capability is limited record
      Instance : Cxx.Block.Dispatcher.Dispatcher_Capability;
   end record;

end Componolit.Interfaces.Internal.Block;
