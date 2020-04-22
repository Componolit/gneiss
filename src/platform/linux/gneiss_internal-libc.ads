
with System;

package Gneiss_Internal.Libc with
   SPARK_Mode
is

   use type System.Address;

   function Strlen (S : System.Address) return Integer with
      Pre           => S /= System.Null_Address,
      Import,
      Convention    => C,
      External_Name => "strlen",
      Global        => null;

end Gneiss_Internal.Libc;
