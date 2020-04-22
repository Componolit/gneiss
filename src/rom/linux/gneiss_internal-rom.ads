
with System;
with Gneiss;

package Gneiss_Internal.Rom with
   SPARK_Mode
is

   type Client_Session is limited record
      Fd    : File_Descriptor             := -1;
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Label : Session_Label;
      Map   : System.Address              := System.Null_Address;
   end record;

end Gneiss_Internal.Rom;
