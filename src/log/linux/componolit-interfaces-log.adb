
with System;

package body Componolit.Interfaces.Log with
   SPARK_Mode
is
   use type System.Address;

   function Initialized (C : Client_Session) return Boolean is
      (C.Label /= System.Null_Address);

   function Maximum_Message_Length (C : Client_Session) return Integer is
      (4095);

end Componolit.Interfaces.Log;
