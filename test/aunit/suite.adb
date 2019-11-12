
with Componolit.Gneiss.Strings.Tests;
with Fifo_Tests;
with Slicer_Tests;

package body Suite
is

   Result : aliased Aunit.Test_Suites.Test_Suite;

   Strings_Case : aliased Componolit.Gneiss.Strings.Tests.Test_Case;
   Fifo_Case    : aliased Fifo_Tests.Test_Case;
   Slicer_Case  : aliased Slicer_Tests.Test_Case;

   function Suite return Aunit.Test_Suites.Access_Test_Suite
   is
   begin
      Result.Add_Test (Strings_Case'Access);
      Result.Add_Test (Fifo_Case'Access);
      Result.Add_Test (Slicer_Case'Access);
      return Result'Access;
   end Suite;

end Suite;
