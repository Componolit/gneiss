
with System;

package Componolit.Interfaces.Internal.Configuration is

   type Client_Session is limited record
      Ifd   : Integer;
      Parse : System.Address;
      Cap   : System.Address;
   end record;

end Componolit.Interfaces.Internal.Configuration;
