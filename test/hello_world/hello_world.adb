
with Cai.Log;
with Cai.Log.Client;

package body Hello_World with
   SPARK_Mode
is

   procedure Construct (Cap : Cai.Types.Capability)
   is
      Log : Cai.Log.Client_Session := Cai.Log.Client.Create;
      Ml : Integer;
   begin
      Cai.Log.Client.Initialize (Log, Cap, "Hello_World");
      if Cai.Log.Client.Initialized (Log) then
         Ml := Cai.Log.Client.Maximum_Message_Length (Log);
         Cai.Log.Client.Info (Log, "Hello World!");
         pragma Assert (Ml = Cai.Log.Client.Maximum_Message_Length (Log));
         Cai.Log.Client.Warning (Log, "Hello World!");
         Cai.Log.Client.Error (Log, "Hello World!");
         Cai.Log.Client.Finalize (Log);
      end if;
   end Construct;

end Hello_World;
