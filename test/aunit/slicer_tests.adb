
with Aunit.Assertions;
with Componolit.Gneiss.Slicer;

package body Slicer_Tests
is

   procedure Test_Positive (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      package Slicer is new Componolit.Gneiss.Slicer (Positive);
      S : Slicer.Context := Slicer.Create (1, 7, 3);
   begin
      Aunit.Assertions.Assert (Slicer.First (S) = 1, "Start not at 1");
      Aunit.Assertions.Assert (Slicer.Last (S) = 3, "First slice end not at 3");
      Aunit.Assertions.Assert (Slicer.Has_Next (S), "Missing second slice");
      Slicer.Next (S);
      Aunit.Assertions.Assert (Slicer.First (S) = 4, "Second slice first not at 4");
      Aunit.Assertions.Assert (Slicer.Last (S) = 6, "Second slice last not at 6");
      Aunit.Assertions.Assert (Slicer.Has_Next (S), "Missing third slice");
      Slicer.Next (S);
      Aunit.Assertions.Assert (Slicer.First (S) = 7, "Third slice first not at 7");
      Aunit.Assertions.Assert (Slicer.Last (S) = 7, "Third slice last not at 7");
      Aunit.Assertions.Assert (not Slicer.Has_Next (S), "Invalid fourth slice");
   end Test_Positive;

   procedure Test_Integer (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      type List is array (Integer range <>) of Integer;
      package Slicer is new Componolit.Gneiss.Slicer (Integer);
      S : Slicer.Context := Slicer.Create (-3, 4, 3);
   begin
      Aunit.Assertions.Assert (Slicer.First (S) = -3, "First slice first not at -3");
      Aunit.Assertions.Assert (Slicer.Last (S) = -1, "First slice last not at -1");
      Aunit.Assertions.Assert (Slicer.Has_Next (S), "Missing second slice");
      Slicer.Next (S);
      Aunit.Assertions.Assert (Slicer.First (S) = 0, "Second slice first not at 0");
      Aunit.Assertions.Assert (Slicer.Last (S) = 2, "Second slice last not at 2");
      Aunit.Assertions.Assert (Slicer.Has_Next (S), "Missing third slice");
      Slicer.Next (S);
      Aunit.Assertions.Assert (Slicer.First (S) = 3, "Third slice first not at 3");
      Aunit.Assertions.Assert (Slicer.Last (S) = 4, "Third slice last not at 4");
      Aunit.Assertions.Assert (not Slicer.Has_Next (S), "Invalid fourth slice");
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
