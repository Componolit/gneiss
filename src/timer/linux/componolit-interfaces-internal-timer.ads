
with System;

package Componolit.Interfaces.Internal.Timer is

   type Client_Session is limited record
      Instance : System.Address := System.Null_Address;
   end record;

end Componolit.Interfaces.Internal.Timer;
