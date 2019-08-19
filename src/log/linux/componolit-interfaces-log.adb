
with System;

package body Componolit.Interfaces.Log with
   SPARK_Mode
is
   use type System.Address;

   function Create return Client_Session is
      (Client_Session'(Label          => System.Null_Address,
                       Length         => 0,
                       Prev_Nl        => True));

   function Initialized (C : Client_Session) return Boolean is
      (C.Label /= System.Null_Address);

   function Maximum_Message_Length (C : Client_Session) return Integer is
      (4095);

end Componolit.Interfaces.Log;
