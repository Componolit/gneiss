
with Aunit.Assertions;
with Componolit.Gneiss.Slicer;

package body Slicer_Tests
is

   procedure Test_Positive (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      package Slicer is new Componolit.Gneiss.Slicer (Positive);
      S : Slicer.Context := Slicer.Create (1, 7, 3);
      R : Slicer.Slice;
   begin
      R := Slicer.Get_Range (S);
      Aunit.Assertions.Assert (R.First = 1, "First not 1");
      Aunit.Assertions.Assert (R.Last = 7, "Last not 7");
      Aunit.Assertions.Assert (Slicer.Get_Length (S) = 3, "Slice length not 3");
      R := Slicer.Get_Slice (S);
      Aunit.Assertions.Assert (R.First = 1, "Start not at 1");
      Aunit.Assertions.Assert (R.Last = 3, "First slice end not at 3");
      Aunit.Assertions.Assert (Slicer.Has_Next (S), "Missing second slice");
      Slicer.Next (S);
      R := Slicer.Get_Slice (S);
      Aunit.Assertions.Assert (R.First = 4, "Second slice first not at 4");
      Aunit.Assertions.Assert (R.Last = 6, "Second slice last not at 6");
      Aunit.Assertions.Assert (Slicer.Has_Next (S), "Missing third slice");
      Slicer.Next (S);
      R := Slicer.Get_Slice (S);
      Aunit.Assertions.Assert (R.First = 7, "Third slice first not at 7");
      Aunit.Assertions.Assert (R.Last = 7, "Third slice last not at 7");
      Aunit.Assertions.Assert (not Slicer.Has_Next (S), "Invalid fourth slice");
      R := Slicer.Get_Range (S);
      Aunit.Assertions.Assert (R.First = 1, "Range first changed");
      Aunit.Assertions.Assert (R.Last = 7, "Range last changed");
      Aunit.Assertions.Assert (Slicer.Get_Length (S) = 3, "Length changed");
   end Test_Positive;

   procedure Test_Integer (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      type List is array (Integer range <>) of Integer;
      package Slicer is new Componolit.Gneiss.Slicer (Integer);
      S : Slicer.Context := Slicer.Create (-3, 4, 3);
      R : Slicer.Slice;
   begin
      R := Slicer.Get_Range (S);
      Aunit.Assertions.Assert (R.First = -3, "First not -3");
      Aunit.Assertions.Assert (R.Last = 4, "Last not 4");
      Aunit.Assertions.Assert (Slicer.Get_Length (S) = 3, "Slice length not 3");
      R := Slicer.Get_Slice (S);
      Aunit.Assertions.Assert (R.First = -3, "First slice first not at -3");
      Aunit.Assertions.Assert (R.Last = -1, "First slice last not at -1");
      Aunit.Assertions.Assert (Slicer.Has_Next (S), "Missing second slice");
      Slicer.Next (S);
      R := Slicer.Get_Slice (S);
      Aunit.Assertions.Assert (R.First = 0, "Second slice first not at 0");
      Aunit.Assertions.Assert (R.Last = 2, "Second slice last not at 2");
      Aunit.Assertions.Assert (Slicer.Has_Next (S), "Missing third slice");
      Slicer.Next (S);
      R := Slicer.Get_Slice (S);
      Aunit.Assertions.Assert (R.First = 3, "Third slice first not at 3");
      Aunit.Assertions.Assert (R.Last = 4, "Third slice last not at 4");
      Aunit.Assertions.Assert (not Slicer.Has_Next (S), "Invalid fourth slice");
      R := Slicer.Get_Range (S);
      Aunit.Assertions.Assert (R.First = -3, "Range first changed");
      Aunit.Assertions.Assert (R.Last = 4, "Range last changed");
      Aunit.Assertions.Assert (Slicer.Get_Length (S) = 3, "Length changed");
   end Test_Integer;

   procedure Register_Tests (T : in out Test_Case)
   is
      use Aunit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Positive'Access, "Test Positive");
      Register_Routine (T, Test_Integer'Access, "Test Integer");
   end Register_Tests;

   function Name (T : Test_Case) return Aunit.Message_String
   is
   begin
      return Aunit.Format ("Componolit.Gneiss.Slicer");
   end Name;

end Slicer_Tests;
