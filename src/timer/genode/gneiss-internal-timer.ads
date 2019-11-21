
with System;
with Cxx.Timer.Client;

package Gneiss.Internal.Timer is

   type Client_Session is limited record
      Instance : Cxx.Timer.Client.Class := (Session => System.Null_Address);
   end record;

end Gneiss.Internal.Timer;
