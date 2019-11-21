
with System;
with Cxx.Configuration.Client;

package Gneiss.Internal.Rom is

   type Client_Session is limited record
      Instance : Cxx.Configuration.Client.Class := (Config => System.Null_Address);
   end record;

end Gneiss.Internal.Rom;
