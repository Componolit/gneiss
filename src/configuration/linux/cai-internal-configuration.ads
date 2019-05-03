
with System;

package Cai.Internal.Configuration is

   type Client_Session is limited record
      Ifd   : Integer;
      Parse : System.Address;
      Cap   : System.Address;
   end record;

end Cai.Internal.Configuration;
