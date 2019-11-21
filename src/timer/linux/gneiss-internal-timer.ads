
with System;

package Gneiss.Internal.Timer is

   type Client_Session is limited record
      Instance : System.Address := System.Null_Address;
   end record;

end Gneiss.Internal.Timer;
