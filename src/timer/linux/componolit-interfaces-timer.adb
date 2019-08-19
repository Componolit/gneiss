
with System;

package body Componolit.Interfaces.Timer with
   SPARK_Mode
is
   use type System.Address;

   function Create return Client_Session is
      (Client_Session'(Instance => System.Null_Address));

   function Initialized (C : Client_Session) return Boolean is
      (C.Instance /= System.Null_Address);

end Componolit.Interfaces.Timer;
