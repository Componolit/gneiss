
package body Componolit.Gneiss.Slicer with
   SPARK_Mode
is

   function Create (Range_First  : Index;
                    Range_Last   : Index;
                    Slice_Length : Index) return Context
   is
      Sf : Index;
      Sl : Index;
   begin
      Sf := Range_First;
      if Range_Last - Range_First + 1 < Slice_Length then
         Sl := Range_Last;
      else
         Sl := Range_First + (Slice_Length - 1);
      end if;
      return Context'(Full_Range   => (First => Range_First,
                                       Last  => Range_Last),
                      Slice_Range  => (First => Sf,
                                       Last  => Sl),
                      Slice_Length => Slice_Length);
   end Create;

   function Get_Slice (C : Context) return Slice is
      (C.Slice_Range);

   function Get_Range (C : Context) return Slice is
      (C.Full_Range);

   function Get_Length (C : Context) return Index is
      (C.Slice_Length);

   function Has_Next (C : Context) return Boolean is
      (C.Slice_Range.Last < C.Full_Range.Last);

   procedure Next (C : in out Context)
   is
      Slice_First : Index;
      Slice_Last  : Index;
   begin
      Slice_First := C.Slice_Range.Last + 1;
      if C.Full_Range.Last - C.Slice_Range.Last < C.Slice_Length then
         Slice_Last := C.Full_Range.Last;
      else
         Slice_Last := C.Slice_Range.Last + C.Slice_Length;
      end if;
      C := Context'(Full_Range   => (First => C.Full_Range.First,
                                     Last  => C.Full_Range.Last),
                    Slice_Range  => (First => Slice_First,
                                     Last  => Slice_Last),
                    Slice_Length => C.Slice_Length);
   end Next;

end Componolit.Gneiss.Slicer;
