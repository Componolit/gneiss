
with System;

package Gneiss.Internal.Rom is

   type Client_Session is limited record
      Ifd   : Integer        := -1;
      Parse : System.Address := System.Null_Address;
      Cap   : System.Address := System.Null_Address;
      Name  : System.Address := System.Null_Address;
   end record;

end Gneiss.Internal.Rom;
