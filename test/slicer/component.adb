
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;
with Componolit.Gneiss.Slicer;

package body Component with
   SPARK_Mode
is

   package Slicer is new Componolit.Gneiss.Slicer (Positive);

   Log      : Gns.Log.Client_Session;
   Alphabet : String (1 .. 26);

   procedure Construct (Cap : Gns.Types.Capability)
   is
      S : Slicer.Context := Slicer.Create (Alphabet'First, Alphabet'Last, 5);
   begin
      Gns.Log.Client.Initialize (Log, Cap, "log_slicer");
      if not Gns.Log.Initialized (Log) then
         Main.Vacate (Cap, Main.Failure);
         return;
      end if;
      for I in Alphabet'Range loop
         Alphabet (I) := Character'Val (I + 64);
      end loop;
      loop
         pragma Loop_Invariant (Gns.Log.Initialized (Log));
         Gns.Log.Client.Info (Log, Alphabet (Slicer.First (S) .. Slicer.Last (S)));
         exit when not Slicer.Has_Next (S);
         Slicer.Next (S);
      end loop;
      Main.Vacate (Cap, Main.Success);
   end Construct;

   procedure Destruct
   is
   begin
      Gns.Log.Client.Finalize (Log);
   end Destruct;

end Component;
