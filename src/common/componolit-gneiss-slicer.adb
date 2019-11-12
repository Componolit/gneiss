
package body Componolit.Gneiss.Slicer with
   SPARK_Mode
is

   function Create (Range_First : Index;
                    Range_Last  : Index;
                    Slice       : Index) return Context
   is
      Sf : Index;
      Sl : Index;
   begin
      if Range_Last - Range_First + 1 < Slice then
         Sf := Range_First;
         Sl := Range_Last;
      else
         Sf := Range_First;
         Sl := Range_First + Slice - 1;
      end if;
      return Context'(Range_First => Range_First,
                      Range_Last  => Range_Last,
                      Slice       => Slice,
                      Slice_First => Sf,
                      Slice_Last  => Sl);
   end Create;

   function First (C : Context) return Index is
      (C.Slice_First);

   function Last (C : Context) return Index is
      (C.Slice_Last);

   function Has_Next (C : Context) return Boolean is
      (C.Slice_Last < C.Range_Last);

   procedure Next (C : in out Context)
   is
      Slice_First : Index;
      Slice_Last  : Index;
   begin
      Slice_First := C.Slice_Last + 1;
      if C.Range_Last - C.Slice_Last < C.Slice then
         Slice_Last := C.Range_Last;
      else
         Slice_Last := C.Slice_Last + C.Slice;
      end if;
      C := Context'(Range_First => C.Range_First,
                    Range_Last  => C.Range_Last,
                    Slice       => C.Slice,
                    Slice_First => Slice_First,
                    Slice_Last  => Slice_Last);
   end Next;

end Componolit.Gneiss.Slicer;
