
with Cai.Types;
with Cai.Component;
with Cai.Block;
with Cai.Block.Server;
with Cai.Block.Dispatcher;

package Component is

   procedure Construct (Cap : Cai.Types.Capability);

   package Server_Component is new Cai.Component (Construct);

   type Byte is mod 2 ** 8;
   type Buffer is array (Long_Integer range <>) of Byte;

   package Block is new Cai.Block (Byte, Long_Integer, Buffer);

   procedure Event;
   function Block_Count (S : Block.Server_Instance) return Block.Count;
   function Block_Size (S : Block.Server_Instance) return Block.Size;
   function Writable (S : Block.Server_Instance) return Boolean;
   function Maximum_Transfer_Size (S : Block.Server_Instance) return Block.Byte_Length;
   procedure Initialize (S : Block.Server_Instance; L : String; B : Block.Byte_Length);
   procedure Finalize (S : Block.Server_Instance);

   procedure Request;

   package Block_Server is new Block.Server (Event,
                                             Block_Count,
                                             Block_Size,
                                             Writable,
                                             Maximum_Transfer_Size,
                                             Initialize,
                                             Finalize);
   package Block_Dispatcher is new Block.Dispatcher (Block_Server, Request);

end Component;
