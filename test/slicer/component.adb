
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
      R : Slicer.Slice;
   begin
      Gns.Log.Client.Initialize (Log, Cap, "log_slicer");
      if not Gns.Log.Initialized (Log) then
         Main.Vacate (Cap, Main.Failure);
         return;
      end if;
      for I in Alphabet'Range loop
         Alphabet (I) := Character'Val (I + 64);
      end loop;
      --  R := Slicer.Get_Range (S);
      --  pragma Assert (R.First = Alphabet'First);
      --  pragma Assert (R.Last = Alphabet'Last);
      --  pragma Assert (Slicer.Get_Length (S) = 5);
      --  R := Slicer.Get_Slice (S);
      --  pragma Assert (R.Last - R.First + 1 <= Slicer.Get_Length (S));
      --  pragma Assert (Alphabet (R.First .. R.Last)'Length <= Slicer.Get_Length (S));
      loop
         pragma Loop_Invariant (Gns.Log.Initialized (Log));
         pragma Loop_Invariant (Slicer.Get_Range (S).First = Alphabet'First);
         pragma Loop_Invariant (Slicer.Get_Range (S).Last = Alphabet'Last);
         --  pragma Loop_Invariant (Slicer.Get_Length (S) = 5);
         --  pragma Loop_Invariant (Alphabet (R.First .. R.Last)'Length <= Slicer.Get_Length (S));
         R := Slicer.Get_Slice (S);
         Gns.Log.Client.Info (Log, Alphabet (R.First .. R.Last));
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
