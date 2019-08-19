
with System;

package body Componolit.Interfaces.Rom with
   SPARK_Mode
is
   use type System.Address;

   function Create return Client_Session is
      (Client_Session'(Ifd   => -1,
                       Parse => System.Null_Address,
                       Cap   => System.Null_Address,
                       Name  => System.Null_Address));

   function Initialized (C : Client_Session) return Boolean is
      (C.Ifd       >= 0
       and C.Parse /= System.Null_Address
       and C.Cap   /= System.Null_Address
       and C.Name  /= System.Null_Address);

end Componolit.Interfaces.Rom;
