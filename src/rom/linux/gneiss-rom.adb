
with System;

package body Gneiss.Rom with
   SPARK_Mode
is
   use type System.Address;

   function Initialized (C : Client_Session) return Boolean is
      (C.Ifd       >= 0
       and C.Parse /= System.Null_Address
       and C.Cap   /= System.Null_Address
       and C.Name  /= System.Null_Address);

end Gneiss.Rom;
