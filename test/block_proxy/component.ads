
with Gneiss;
with Gneiss.Component;
with Gneiss.Block;
with Gneiss.Block.Client;
with Gneiss.Block.Dispatcher;
with Gneiss.Block.Server;

package Component is

   procedure Construct (Cap : Gneiss.Capability);
   procedure Destruct;

   package Main is new Gneiss.Component (Construct, Destruct);

   type Byte is mod 2 ** 8;
   subtype Unsigned_Long is Long_Integer range 0 .. Long_Integer'Last;
   type Buffer is array (Unsigned_Long range <>) of Byte;
   type Request_Index is mod 2 ** 6;

   package Block is new Gneiss.Block (Byte, Unsigned_Long, Buffer, Integer, Request_Index);

   use type Block.Count;

   procedure Event;

   procedure Write (C : in out Block.Client_Session;
                    I :        Request_Index;
                    D :    out Buffer) with
      Pre => Block.Initialized (C);

   procedure Read (C : in out Block.Client_Session;
                   I :        Request_Index;
                   D :        Buffer) with
      Pre => Block.Initialized (C);

   package Block_Client is new Block.Client (Event, Read, Write);

   procedure Dispatch (I : in out Block.Dispatcher_Session;
                       C :        Block.Dispatcher_Capability) with
      Pre => Block.Initialized (I) and then not Block.Accepted (I);
   function Initialized (S : Block.Server_Session) return Boolean;
   procedure Initialize_Server (S : in out Block.Server_Session;
                                L :        String;
                                B :        Block.Byte_Length) with
      Pre => not Initialized (S);
   procedure Finalize_Server (S : in out Block.Server_Session) with
      Pre => Initialized (S);
   function Block_Count (S : Block.Server_Session) return Block.Count with
      Pre => Initialized (S),
      Post => Block_Count'Result > 0;
   function Block_Size (S : Block.Server_Session) return Block.Size with
      Pre => Initialized (S),
      Post => Block_Size'Result in 512 | 1024 | 2048 | 4096;
   function Writable (S : Block.Server_Session) return Boolean with
      Pre => Initialized (S);

   procedure Write (S : in out Block.Server_Session;
                    I :        Request_Index;
                    D :        Buffer);

   procedure Read (S : in out Block.Server_Session;
                   I :        Request_Index;
                   D :    out Buffer);

   package Block_Server is new Block.Server (Event,
                                             Block_Count,
                                             Block_Size,
                                             Writable,
                                             Initialized,
                                             Initialize_Server,
                                             Finalize_Server,
                                             Read,
                                             Write);
   package Block_Dispatcher is new Block.Dispatcher (Block_Server, Dispatch);

end Component;
