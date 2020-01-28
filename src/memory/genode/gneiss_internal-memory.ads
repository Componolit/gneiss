
with Gneiss;
with System;

package Gneiss_Internal.Memory with
   SPARK_Mode
is

   type Client_Session is limited record
      Index    : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Writable : Boolean                     := False;
      Rom      : System.Address              := System.Null_Address;
      Event    : System.Address              := System.Null_Address;
      Modify   : System.Address              := System.Null_Address;
   end record;

end Gneiss_Internal.Memory;
