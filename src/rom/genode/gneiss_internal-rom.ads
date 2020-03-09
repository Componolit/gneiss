
with Gneiss;
with System;

package Gneiss_Internal.Rom with
   SPARK_Mode
is

   type Client_Session is limited record
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Rom   : System.Address              := System.Null_Address;
      Read  : System.Address              := System.Null_Address;
   end record;

end Gneiss_Internal.Rom;
