
with Gneiss;
with System;

package Gneiss_Internal.Message with
   SPARK_Mode
is

   type Client_Session is limited record
      Connection : System.Address              := System.Null_Address;
      Index      : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Event      : System.Address              := System.Null_Address;
      Init       : System.Address              := System.Null_Address;
   end record;

   type Server_Session is limited record
      null;
   end record;

   type Dispatcher_Session is limited record
      null;
   end record;

   type Dispatcher_Capability is limited record
      null;
   end record;

end Gneiss_Internal.Message;
