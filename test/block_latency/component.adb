
with Cai.Log;
with Cai.Log.Client;
with Cai.Block;
with Cai.Block.Client;
with Rwr;

package body Component with
   SPARK_Mode
is

   procedure Event;

   type Byte is mod 2 ** 8;
   type Buffer is array (Long_Integer range <>) of Byte;

   package Block is new Cai.Block (Byte, Long_Integer, Buffer);

   package Block_Client is new Block.Client (Event);
   Client : Block.Client_Session;
   Log    : Cai.Log.Client_Session;
   Xml    : Cai.Log.Client_Session;

   generic
      with package B is new Cai.Block (<>);
      with package BC is new B.Client (<>);
      Last_Burst         : B.Count;
      Last_Iterations    : Positive;
      Current_Burst      : B.Count;
      Current_Iterations : Positive;
      with package Last is new Rwr (B, BC, Last_Burst, Last_Iterations);
      with package Current is new Rwr (B, BC, Current_Burst, Current_Iterations);
      Name : String;
   procedure Checked_Run (L :        Last.Rwr_Run;
                          C : in out Current.Rwr_Run;
                          S : in out B.Client_Session);

   procedure Pre_Print (Test : String);
   procedure Post_Print (Finished : Boolean);

   procedure Checked_Run (L :        Last.Rwr_Run;
                          C : in out Current.Rwr_Run;
                          S : in out B.Client_Session)
   is
   begin
      if Last.Finished (L) and not Current.Finished (C) then
         Pre_Print (Name);
         Current.Run (S, C, Log);
         Post_Print (Current.Finished (C));
      end if;
   end Checked_Run;

   package Small_1 is new Rwr (Block, Block_Client, 1, 100);
   package Small_2 is new Rwr (Block, Block_Client, 2, 100);
   package Small_4 is new Rwr (Block, Block_Client, 4, 100);

   package Medium_500 is new Rwr (Block, Block_Client, 500, 100);
   package Medium_1000 is new Rwr (Block, Block_Client, 1000, 100);
   package Medium_5000 is new Rwr (Block, Block_Client, 5000, 100);

   package Large_50000 is new Rwr (Block, Block_Client, 50000, 10);
   package Large_100000 is new Rwr (Block, Block_Client, 100000, 10);
--   package Large_250000 is new Rwr (Block, Block_Client, 250000, 5);
--   package Large_1000000 is new Rwr (Block, Block_Client, 1000000, 2);

   Small_1_Data      : Small_1.Rwr_Run;
   Small_2_Data      : Small_2.Rwr_Run;
   Small_4_Data      : Small_4.Rwr_Run;

   Medium_500_Data   : Medium_500.Rwr_Run;
   Medium_1000_Data  : Medium_1000.Rwr_Run;
   Medium_5000_Data  : Medium_5000.Rwr_Run;

   Large_50000_Data  : Large_50000.Rwr_Run;
   Large_100000_Data : Large_100000.Rwr_Run;
--   Large_250000_Data : Large_250000.Rwr_Run;
--   Large_1000000_Data : Large_1000000.Rwr_Run;

   procedure Small_2_Run is new Checked_Run (Block, Block_Client, 1, 100, 2, 100, Small_1, Small_2, "Small_2");
   procedure Small_4_Run is new Checked_Run (Block, Block_Client, 2, 100, 4, 100, Small_2, Small_4, "Small_4");

   procedure Medium_500_Run is new Checked_Run (Block, Block_Client, 4, 100, 500, 100,
                                                Small_4, Medium_500, "Medium_500");
   procedure Medium_1000_Run is new Checked_Run (Block, Block_Client, 500, 100, 1000, 100,
                                                 Medium_500, Medium_1000, "Medium_1000");
   procedure Medium_5000_Run is new Checked_Run (Block, Block_Client, 1000, 100, 5000, 100,
                                                 Medium_1000, Medium_5000, "Medium_5000");

   procedure Large_50000_Run is new Checked_Run (Block, Block_Client, 5000, 100, 50000, 10,
                                                 Medium_5000, Large_50000, "Large_50000");
   procedure Large_100000_Run is new Checked_Run (Block, Block_Client, 50000, 10, 100000, 10,
                                                  Large_50000, Large_100000, "Large_100000");
--   procedure Large_250000_Run is new Checked_Run (Block, Block_Client, 100000, 10, 250000, 5,
   --                                               Large_100000, Large_250000, "Large_250000");
--   procedure Large_1000000_Run is new Checked_Run (Block, Block_Client, 250000, 5, 1000000, 2,
   --                                                Large_250000, Large_1000000, "Large_1000000");

   procedure Construct (Cap : Cai.Types.Capability) is
   begin
      Cai.Log.Client.Initialize (Log, Cap, "Latency");
      Cai.Log.Client.Info (Log, "Initializing test data");
      Cai.Log.Client.Initialize (Xml, Cap, "XML");
      Block_Client.Initialize (Client, Cap, "");
      Small_1.Initialize (Small_1_Data);
      Small_2.Initialize (Small_2_Data);
      Small_4.Initialize (Small_4_Data);
      Medium_500.Initialize (Medium_500_Data);
      Medium_1000.Initialize (Medium_1000_Data);
      Medium_5000.Initialize (Medium_5000_Data);
      Large_50000.Initialize (Large_50000_Data);
      Large_100000.Initialize (Large_100000_Data);
--      Large_250000.Initialize (Large_250000_Data);
--      Large_1000000.Initialize (Large_1000000_Data);
      Event;
   end Construct;

   Printed : Boolean := False;

   procedure Pre_Print (Test : String)
   is
   begin
      if not Printed then
         Cai.Log.Client.Info (Log, "Test: " & Test);
         Printed := True;
      end if;
   end Pre_Print;

   procedure Post_Print (Finished : Boolean)
   is
   begin
      if Finished then
         Cai.Log.Client.Flush (Log);
         Printed := False;
      end if;
   end Post_Print;

   procedure Event is
   begin
      if not Small_1.Finished (Small_1_Data) then
         Pre_Print ("Small_1");
         Small_1.Run (Client, Small_1_Data, Log);
         Post_Print (Small_1.Finished (Small_1_Data));
      end if;
      Small_2_Run (Small_1_Data, Small_2_Data, Client);
      Small_4_Run (Small_2_Data, Small_4_Data, Client);
      Medium_500_Run (Small_4_Data, Medium_500_Data, Client);
      Medium_1000_Run (Medium_500_Data, Medium_1000_Data, Client);
      Medium_5000_Run (Medium_1000_Data, Medium_5000_Data, Client);
      Large_50000_Run (Medium_5000_Data, Large_50000_Data, Client);
      Large_100000_Run (Large_50000_Data, Large_100000_Data, Client);
--      Large_250000_Run (Large_100000_Data, Large_250000_Data, Client);
--      Large_1000000_Run (Large_250000_Data, Large_1000000_Data, Client);
      if
         Small_1.Finished (Small_1_Data)
         and Small_2.Finished (Small_2_Data)
         and Small_4.Finished (Small_4_Data)
         and Medium_500.Finished (Medium_500_Data)
         and Medium_1000.Finished (Medium_1000_Data)
         and Medium_5000.Finished (Medium_5000_Data)
         and Large_50000.Finished (Large_50000_Data)
         and Large_100000.Finished (Large_100000_Data)
--         and Large_250000.Finished (Large_250000_Data)
--         and Large_1000000.Finished (Large_1000000_Data)
      then
         Cai.Log.Client.Info (Log, "Tests finished, writing data...");
         Cai.Log.Client.Info (Xml, "<test name=""Latency"" platform=""Genode"" hardware=""Qemu"" block_size="""
                                   & Cai.Log.Image (Long_Integer (Block_Client.Block_Size (Client)))
                                   & """>");
         Cai.Log.Client.Info (Log, "Small_1...");
         Small_1.Xml (Xml, Small_1_Data, Log);
         Cai.Log.Client.Info (Log, "Small_2...");
         Small_2.Xml (Xml, Small_2_Data, Log);
         Cai.Log.Client.Info (Log, "Small_4...");
         Small_4.Xml (Xml, Small_4_Data, Log);
         Cai.Log.Client.Info (Log, "Medium_500...");
         Medium_500.Xml (Xml, Medium_500_Data, Log);
         Cai.Log.Client.Info (Log, "Medium_1000...");
         Medium_1000.Xml (Xml, Medium_1000_Data, Log);
         Cai.Log.Client.Info (Log, "Medium_5000...");
         Medium_5000.Xml (Xml, Medium_5000_Data, Log);
         Cai.Log.Client.Info (Log, "Large_50000...");
         Large_50000.Xml (Xml, Large_50000_Data, Log);
         Cai.Log.Client.Info (Log, "Large_100000...");
         Large_100000.Xml (Xml, Large_100000_Data, Log);
--         Cai.Log.Client.Info (Log, "Large_250000...");
--         Large_250000.Xml (Xml, Large_250000_Data, Log);
--         Cai.Log.Client.Info (Log, "Large_1000000...");
--         Large_1000000.Xml (Xml, Large_1000000_Data, Log);
         Cai.Log.Client.Info (Xml, "</test>");
         Cai.Log.Client.Flush (Xml);
         Cai.Log.Client.Info (Log, "Data written.");
         Cai.Log.Client.Flush (Log);
      end if;
   end Event;

end Component;
