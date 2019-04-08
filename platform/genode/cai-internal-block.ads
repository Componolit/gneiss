
with System;
with Cxx;
with Cxx.Block.Dispatcher;

package Cai.Internal.Block is

   type Private_Data is new Cxx.Genode_Uint8_T_Array (1 .. 16);
   Null_Data : Private_Data := (others => 0);
   type Client_Session is record
      Instance : System.Address;
   end record;
   type Dispatcher_Session is limited record
      Instance : Cxx.Block.Dispatcher.Class;
   end record;
   type Server_Session is record
      Instance : System.Address;
   end record;
   type Client_Instance is new System.Address;
   type Dispatcher_Instance is new System.Address;
   type Server_Instance is new System.Address;

end Cai.Internal.Block;
