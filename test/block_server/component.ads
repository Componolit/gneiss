
with Componolit.Interfaces.Types;
with Componolit.Interfaces.Component;
with Componolit.Interfaces.Block;
with Componolit.Interfaces.Block.Server;
with Componolit.Interfaces.Block.Dispatcher;

package Component is

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability);
   procedure Destruct;

   package Main is new Componolit.Interfaces.Component (Construct, Destruct);

   type Byte is mod 2 ** 8;
   subtype Unsigned_Long is Long_Integer range 0 .. Long_Integer'Last;
   type Buffer is array (Unsigned_Long range <>) of Byte;

   package Block is new Componolit.Interfaces.Block (Byte, Unsigned_Long, Buffer);

   procedure Event;
   function Block_Count (S : Block.Server_Instance) return Block.Count;
   function Block_Size (S : Block.Server_Instance) return Block.Size;
   function Writable (S : Block.Server_Instance) return Boolean;
   function Initialized (S : Block.Server_Instance) return Boolean;
   procedure Initialize (S : Block.Server_Instance; L : String; B : Block.Byte_Length);
   procedure Finalize (S : Block.Server_Instance);

   procedure Request (C : Block.Dispatcher_Capability);

   package Block_Server is new Block.Server (Event,
                                             Block_Count,
                                             Block_Size,
                                             Writable,
                                             Initialized,
                                             Initialize,
                                             Finalize);
   package Block_Dispatcher is new Block.Dispatcher (Block_Server, Request);

end Component;
