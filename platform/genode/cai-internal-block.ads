
with System;
with Cxx;
with Cxx.Block.Client;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;

package Cai.Internal.Block is

   type Private_Data is new Cxx.Genode_Uint8_T_Array (1 .. 16);
   Null_Data : Private_Data := (others => 0);
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
   Null_Client : constant Client_Instance := Client_Instance (System.Null_Address);
   type Dispatcher_Instance is new System.Address;
   Null_Dispatcher : constant Dispatcher_Instance := Dispatcher_Instance (System.Null_Address);
   type Server_Instance is new System.Address;
   Null_Server : constant Server_Instance := Server_Instance (System.Null_Address);

end Cai.Internal.Block;
