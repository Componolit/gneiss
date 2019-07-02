
with Componolit.Interfaces.Types;
with Componolit.Interfaces.Component;
with Componolit.Interfaces.Block;
with Componolit.Interfaces.Block.Client;
with Componolit.Interfaces.Block.Dispatcher;
with Componolit.Interfaces.Block.Server;

package Component is

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability);
   procedure Destruct;

   package Main is new Componolit.Interfaces.Component (Construct, Destruct);

   type Byte is mod 2 ** 8;
   subtype Unsigned_Long is Long_Integer range 0 .. Long_Integer'Last;
   type Buffer is array (Unsigned_Long range <>) of Byte;

   package Block is new Componolit.Interfaces.Block (Byte, Unsigned_Long, Buffer);

   procedure Event;
   procedure Dispatch;
   procedure Initialize_Server (S : Block.Server_Instance; L : String; B : Block.Byte_Length);
   procedure Finalize_Server (S : Block.Server_Instance);
   function Block_Count (S : Block.Server_Instance) return Block.Count;
   function Block_Size (S : Block.Server_Instance) return Block.Size;
   function Writable (S : Block.Server_Instance) return Boolean;
   function Maximum_Transfer_Size (S : Block.Server_Instance) return Block.Byte_Length;

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
                                             Maximum_Transfer_Size,
                                             Initialize_Server,
                                             Finalize_Server);
   package Block_Dispatcher is new Block.Dispatcher (Block_Server, Dispatch);

end Component;
