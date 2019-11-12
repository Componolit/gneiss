
generic
   type Index is range <>;
package Componolit.Gneiss.Slicer with
   SPARK_Mode
is

   type Context is private;

   function Create (Range_First : Index;
                    Range_Last  : Index;
                    Slice       : Index) return Context with
      Pre => Range_First < Range_Last;

   function First (C : Context) return Index;

   function Last (C : Context) return Index;

   function Has_Next (C : Context) return Boolean;

   procedure Next (C : in out Context) with
      Pre => Has_Next (C);

private

   type Context is record
      Range_First : Index;
      Range_Last  : Index;
      Slice       : Index;
      Slice_First : Index;
      Slice_Last  : Index;
   end record with
      Dynamic_Predicate => Range_First < Range_Last
                        and then Slice_First in Range_First .. Range_Last
                        and then Slice_Last in Range_First .. Range_Last
                        and then Slice_First < Slice_Last
                        and then Slice_Last - Slice_First + 1 <= Slice;

end Componolit.Gneiss.Slicer;
