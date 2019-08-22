
with Componolit.Gneiss.Strings.Tests;

package body Suite
is

   Result : aliased Aunit.Test_Suites.Test_Suite;

   Strings_Case : aliased Componolit.Gneiss.Strings.Tests.Test_Case;

   function Suite return Aunit.Test_Suites.Access_Test_Suite
   is
   begin
      Result.Add_Test (Strings_Case'Access);
      return Result'Access;
   end Suite;

end Suite;
