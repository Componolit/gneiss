
with Cai.Types;
with Cai.Component;
with Cai.Block;
with Cai.Block.Client;
with Cai.Block.Dispatcher;
with Cai.Block.Server;

package Component is

   procedure Construct (Cap : Cai.Types.Capability);

   package Proxy_Component is new Cai.Component (Construct);

   type Byte is mod 2 ** 8;
   type Buffer is array (Long_Integer range <>) of Byte;

   package Block is new Cai.Block (Byte, Long_Integer, Buffer);

   procedure Event;
   procedure Dispatch;
   procedure Initialize_Server (S : Block.Server_Instance; L : String);
   procedure Finalize_Server (S : Block.Server_Instance);
   function Block_Count (S : Block.Server_Instance) return Block.Count;
   function Block_Size (S : Block.Server_Instance) return Block.Size;
   function Writable (S : Block.Server_Instance) return Boolean;
   function Maximal_Transfer_Size (S : Block.Server_Instance) return Block.Byte_Length;

   procedure Write (C :     Block.Client_Instance;
                    B :     Block.Size;
                    S :     Block.Id;
                    L :     Block.Count;
                    D : out Buffer);

   procedure Read (C : Block.Client_Instance;
                   B : Block.Size;
                   S : Block.Id;
                   L : Block.Count;
                   D : Buffer);

   package Block_Client is new Block.Client (Event, Read, Write);
   package Block_Server is new Block.Server (Event,
                                             Block_Count,
                                             Block_Size,
                                             Writable,
                                             Maximal_Transfer_Size,
                                             Initialize_Server,
                                             Finalize_Server);
   package Block_Dispatcher is new Block.Dispatcher (Block_Server, Dispatch);

end Component;
