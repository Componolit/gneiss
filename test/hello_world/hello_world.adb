
with Cai.Log;
with Cai.Log.Client;

package body Hello_World is

   procedure Construct
   is
      Log : Cai.Log.Client_Session;
   begin
      Cai.Log.Client.Initialize (Log, "Hello_World");
      Cai.Log.Client.Info (Log, "Hello World!");
      Cai.Log.Client.Warning (Log, "Hello World!");
      Cai.Log.Client.Error (Log, "Hello World!");
      Cai.Log.Client.Finalize (Log);
   end Construct;

end Hello_World;
