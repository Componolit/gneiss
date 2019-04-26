
with C;
with System;

package Cai.Internal.Configuration is

   type Client_Session is limited record
      Fd   : Integer;
      Map  : System.Address;
      Size : C.Uint64_T;
      Ifd  : Integer;
      Load : System.Address;
      Cap  : System.Address;
   end record;

end Cai.Internal.Configuration;
