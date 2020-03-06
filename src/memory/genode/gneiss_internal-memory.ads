
with Gneiss;
with System;

package Gneiss_Internal.Memory with
   SPARK_Mode
is

   type Client_Session is limited record
      Session : System.Address              := System.Null_Address;
      Index   : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
   end record;

   type Server_Session is limited record
      Component : System.Address              := System.Null_Address;
      Addr      : System.Address              := System.Null_Address;
      Size      : Long_Integer                := 0;
      Index     : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
   end record;

   type Dispatcher_Session is limited record
      Root     : System.Address              := System.Null_Address;
      Env      : System.Address              := System.Null_Address;
      Index    : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Dispatch : System.Address              := System.Null_Address;
   end record;

   type Dispatcher_Capability is limited record
      Session : System.Address;
      Size    : Long_Integer;
   end record;

end Gneiss_Internal.Memory;
