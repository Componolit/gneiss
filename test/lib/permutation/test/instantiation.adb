with Permutation;

package body Instantiation with
  SPARK_Mode
is

   procedure Test is
      type Number is mod 2**32;
      package Perm is new Permutation (Number); use Perm;
      N : Number;
   begin
      Initialize (Number'Last);
      while Has_Element loop
         Next (N);
         pragma Inspection_Point (N);
      end loop;
   end Test;

end Instantiation;
