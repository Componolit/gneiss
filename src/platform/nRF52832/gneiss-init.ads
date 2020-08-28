with System;

package Gneiss.Init with
   SPARK_Mode
is

   function Create_Capability (Reg : System.Address;
                               Idx : Natural) return Capability;

end Gneiss.Init;
