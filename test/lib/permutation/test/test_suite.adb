with Permutation.Tests;

package body Test_Suite is

   type N12 is range -2**10 .. 2**10 with Size => 12;
   package Perm_12 is new Permutation (N12);
   package Perm_12_Test is new Perm_12.Tests;

   type N13 is range 0 .. 2**13 - 1 with Size => 13;
   package Perm_13 is new Permutation (N13);
   package Perm_13_Test is new Perm_13.Tests;

   type N14 is mod 2**14;
   package Perm_14 is new Permutation (N14);
   package Perm_14_Test is new Perm_14.Tests;

   function Suite return Access_Test_Suite is
      Result : constant Access_Test_Suite := new AUnit.Test_Suites.Test_Suite;
   begin
      Result.Add_Test (new Perm_12_Test.Test);
      Result.Add_Test (new Perm_13_Test.Test);
      Result.Add_Test (new Perm_14_Test.Test);
      return Result;
   end Suite;

end Test_Suite;
