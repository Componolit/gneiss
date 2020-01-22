
with System;
with Gneiss;

package Gneiss_Internal.Memory with
   SPARK_Mode
is

   type Client_Session is limited record
      Fd       : Integer                     := -1;
      Writable : Boolean                     := False;
      Index    : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Label    : Session_Label;
      Map      : System.Address              := System.Null_Address;
   end record;

end Gneiss_Internal.Memory;
