
with Componolit.Interfaces.Types;
with Componolit.Interfaces.Component;
with Componolit.Interfaces.Block;
with Componolit.Interfaces.Block.Server;
with Componolit.Interfaces.Block.Dispatcher;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability);
   procedure Destruct;

   package Main is new Componolit.Interfaces.Component (Construct, Destruct);

   type Byte is mod 2 ** 8;
   subtype Unsigned_Long is Long_Integer range 0 .. Long_Integer'Last;
   type Buffer is array (Unsigned_Long range <>) of Byte;
   type Request_Index is mod 8;

   package Block is new Componolit.Interfaces.Block (Byte, Unsigned_Long, Buffer, Request_Index);

   use type Block.Count;
   use type Block.Size;

   Disk_Block_Size  : constant Block.Size  := 512;
   Disk_Block_Count : constant Block.Count := 1024;

   procedure Event;
   function Block_Count (S : Block.Server_Instance) return Block.Count with
      Post => Block_Count'Result = Disk_Block_Count;
   function Block_Size (S : Block.Server_Instance) return Block.Size with
      Post => Block_Size'Result = Disk_Block_Size,
      Annotate => (GNATprove, Terminating);
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
