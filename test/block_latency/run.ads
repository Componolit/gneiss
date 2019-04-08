
with Cai.Block;
with Cai.Block.Client;
with Cai.Log;
with Iteration;

generic
   with package Block is new Cai.Block (<>);
   with package Client is new Block.Client (<>);
   Request_Count : Block.Count;
   Run_Count     : Positive;
   Operation     : Block.Request_Kind;
package Run is

   package Iter is new Iteration (Block, Client, Request_Count, Operation);

   type Run_Type is array (1 .. Run_Count) of Iter.Test;

   procedure Initialize (R : out Run_Type;
                         S :     Boolean);

   procedure Run (C   : in out Block.Client_Session;
                  R   : in out Run_Type;
                  Log : in out Cai.Log.Client_Session);

   function Finished (R : Run_Type) return Boolean;

   procedure Xml (Xml_Log : in out Cai.Log.Client_Session;
                  R       :        Run_Type;
                  Cold    :        Boolean;
                  Log     : in out Cai.Log.Client_Session);

end Run;
