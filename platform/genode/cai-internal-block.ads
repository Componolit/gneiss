
with Cxx;
with Cxx.Block.Client;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;

package Cai.Internal.Block is

   type Private_Data is new Cxx.Genode_Uint8_T_Array (1 .. 16);
   Null_Data : Private_Data := (others => 0);
   type Client is limited record
      Instance : Cxx.Block.Client.Class;
   end record;
   type Dispatcher is limited record
      Instance : Cxx.Block.Dispatcher.Class;
   end record;
   type Server is limited record
      Instance : Cxx.Block.Server.Class;
   end record;

end Cai.Internal.Block;
