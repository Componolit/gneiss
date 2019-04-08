with Ada.Real_Time;
with Cai.Block;
with Cai.Block.Client;
with Cai.Log;

generic
   with package Block is new Cai.Block (<>);
   with package Client is new Block.Client (<>);
   Request_Count : Block.Count;
   Operation     : Block.Request_Kind;
package Iteration is

   use all type Block.Id;
   use all type Block.Count;

   type Request is record
      Start   : Ada.Real_Time.Time;
      Finish  : Ada.Real_Time.Time;
      Success : Boolean;
   end record;

   type Burst is array (Long_Integer range <>) of Request;

   type Test is record
      Sent      : Long_Integer;
      Received  : Long_Integer;
      Offset    : Block.Count;
      Finished  : Boolean;
      Sync      : Boolean;
      Buffer    : Block.Buffer (1 .. 4096);
      Data      : Burst (0 .. Long_Integer (Request_Count - 1));
   end record;

   procedure Initialize (T      : out Test;
                         Offset :     Block.Count;
                         S      :     Boolean);

   procedure Send (C   : in out Block.Client_Session;
                   T   : in out Test;
                   Log : in out Cai.Log.Client_Session);

   procedure Receive (C   : in out Block.Client_Session;
                      T   : in out Test;
                      Log : in out Cai.Log.Client_Session);

   procedure Xml (Xml_Log : in out Cai.Log.Client_Session;
                  B       :        Burst;
                  Offset  :        Block.Count);

end Iteration;
