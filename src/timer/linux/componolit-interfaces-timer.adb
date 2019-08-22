
with System;

package body Componolit.Interfaces.Timer with
   SPARK_Mode
is
   use type System.Address;

   function Initialized (C : Client_Session) return Boolean is
      (C.Instance /= System.Null_Address);

end Componolit.Interfaces.Timer;
