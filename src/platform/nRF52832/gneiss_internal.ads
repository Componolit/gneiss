with System;

package Gneiss_Internal with
   SPARK_Mode
is

   type Capability is record
      Reg : System.Address;
      Idx : Natural;
   end record;

end Gneiss_Internal;
