
with System;
with Gneiss;
with Cxx.Timer.Client;

package Gneiss_Internal.Timer is

   type Client_Session is limited record
      Instance : Cxx.Timer.Client.Class := (Session => System.Null_Address,
                                            Index   => Gneiss.Session_Index_Option'(Valid => False));
   end record;

end Gneiss_Internal.Timer;
