
with System;
with Cxx.Configuration.Client;

package Componolit.Interfaces.Internal.Rom is

   type Client_Session is limited record
      Instance : Cxx.Configuration.Client.Class := (Config => System.Null_Address);
   end record;

end Componolit.Interfaces.Internal.Rom;
