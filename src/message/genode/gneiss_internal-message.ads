
with Gneiss;
with System;
with Basalt.Queue;

generic
   type Buffer is private;
   Null_Buffer : Buffer;
package Gneiss_Internal.Message with
   SPARK_Mode
is

   package Queue is new Basalt.Queue (Buffer, Null_Buffer);

   type Client_Session is limited record
      Connection : System.Address              := System.Null_Address;
      Index      : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Event      : System.Address              := System.Null_Address;
      Init       : System.Address              := System.Null_Address;
   end record;

   type Server_Session is limited record
      Component : System.Address              := System.Null_Address;
      Index     : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Cache     : Queue.Context (10);
   end record;

   type Dispatcher_Session is limited record
      Root     : System.Address              := System.Null_Address;
      Dispatch : System.Address              := System.Null_Address;
      Env      : System.Address              := System.Null_Address;
      Index    : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
   end record;

   type Dispatcher_Capability is limited record
      Session : System.Address := System.Null_Address;
   end record;

end Gneiss_Internal.Message;
