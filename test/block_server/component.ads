
with Componolit.Gneiss.Types;
with Componolit.Gneiss.Component;
with Componolit.Gneiss.Block;
with Componolit.Gneiss.Block.Server;
with Componolit.Gneiss.Block.Dispatcher;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability);
   procedure Destruct;

   package Main is new Componolit.Gneiss.Component (Construct, Destruct);

   type Byte is mod 2 ** 8;
   subtype Unsigned_Long is Long_Integer range 0 .. Long_Integer'Last;
   type Buffer is array (Unsigned_Long range <>) of Byte;
   type Request_Index is mod 8;

   package Block is new Componolit.Gneiss.Block (Byte, Unsigned_Long, Buffer, Integer, Request_Index);

   use type Block.Count;
   use type Block.Size;

   Disk_Block_Size  : constant Block.Size  := 512;
   Disk_Block_Count : constant Block.Count := 1024;

   procedure Event;
   function Block_Count (S : Block.Server_Session) return Block.Count with
      Post => Block_Count'Result = Disk_Block_Count;
   function Block_Size (S : Block.Server_Session) return Block.Size with
      Post => Block_Size'Result = Disk_Block_Size,
      Annotate => (GNATprove, Terminating);
   function Writable (S : Block.Server_Session) return Boolean;
   function Initialized (S : Block.Server_Session) return Boolean;
   procedure Initialize (S : in out Block.Server_Session;
                         L :        String;
                         B :        Block.Byte_Length);
   procedure Finalize (S : in out Block.Server_Session);

   procedure Request (I : in out Block.Dispatcher_Session;
                      C :        Block.Dispatcher_Capability) with
      Pre => Block.Initialized (I) and then not Block.Accepted (I);

   package Block_Server is new Block.Server (Event,
                                             Block_Count,
                                             Block_Size,
                                             Writable,
                                             Initialized,
                                             Initialize,
                                             Finalize);
   package Block_Dispatcher is new Block.Dispatcher (Block_Server, Request);

end Component;
