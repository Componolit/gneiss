
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
   type Request_Index is mod 8;

   package Block is new Componolit.Interfaces.Block (Byte, Unsigned_Long, Buffer, Request_Index);

   use type Block.Count;

   procedure Event;

   procedure Write (C :     Block.Client_Instance;
                    I :     Request_Index;
                    D : out Buffer) with
      Pre => Block.Initialized (C);

   procedure Read (C : Block.Client_Instance;
                   I : Request_Index;
                   D : Buffer) with
      Pre => Block.Initialized (C);

   package Block_Client is new Block.Client (Event, Read, Write);

   Client : Block.Client_Session := Block.Create;
   Server     : Block.Server_Session     := Block.Create;

   Capability : Componolit.Interfaces.Types.Capability;

   procedure Dispatch (I : Block.Dispatcher_Instance;
                       C : Block.Dispatcher_Capability) with
      Pre => Block.Initialized (I) and then not Block.Accepted (I);
   function Initialized (S : Block.Server_Instance) return Boolean;
   procedure Initialize_Server (S : Block.Server_Instance; L : String; B : Block.Byte_Length) with
      Pre => not Initialized (S),
      Global => (Input => (Server, Capability),
                 In_Out => Client);
   procedure Finalize_Server (S : Block.Server_Instance) with
      Pre => Initialized (S);
   function Block_Count (S : Block.Server_Instance) return Block.Count with
      Pre => Initialized (S),
      Post => Block_Count'Result > 0
      and then Block_Count'Result < Block.Count'Last / (Block.Count (Block.Block_Size (Client)) / 512);
   function Block_Size (S : Block.Server_Instance) return Block.Size with
      Pre => Initialized (S),
      Post => Block_Size'Result in 512 | 1024 | 2048 | 4096;
   function Writable (S : Block.Server_Instance) return Boolean with
      Pre => Initialized (S);

   package Block_Server is new Block.Server (Event,
                                             Block_Count,
                                             Block_Size,
                                             Writable,
                                             Initialized,
                                             Initialize_Server,
                                             Finalize_Server);
   package Block_Dispatcher is new Block.Dispatcher (Block_Server, Dispatch);

end Component;
