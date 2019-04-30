
with Cai.Log;
with Cai.Log.Client;

package body Hello_World with
   SPARK_Mode
is

   Log : Cai.Log.Client_Session := Cai.Log.Client.Create;

   procedure Construct (Cap : Cai.Types.Capability)
   is
      Ml : Integer;
   begin
      Hello_World_Component.Vacate (Cap, Hello_World_Component.Success);
      Cai.Log.Client.Initialize (Log, Cap, "Hello_World");
      if Cai.Log.Client.Initialized (Log) then
         Ml := Cai.Log.Client.Maximum_Message_Length (Log);
         Cai.Log.Client.Info (Log, "Hello World!");
         pragma Assert (Ml = Cai.Log.Client.Maximum_Message_Length (Log));
         Cai.Log.Client.Warning (Log, "Hello World!");
         Cai.Log.Client.Error (Log, "Hello World!");
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Cai.Log.Client.Initialized (Log) then
         Cai.Log.Client.Info (Log, "Destructing...");
         Cai.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Hello_World;
