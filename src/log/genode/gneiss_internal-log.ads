
with Gneiss;
with System;

package Gneiss_Internal.Log is

   type Client_Session is limited record
      Session  : System.Address     := System.Null_Address;
      Buffer   : String (1 .. 4096) := (others => Character'First);
      Cursor   : Positive           := 1;
   end record;

   type Dispatcher_Session is limited record
      Root     : System.Address              := System.Null_Address;
      Env      : System.Address              := System.Null_Address;
      Index    : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      Dispatch : System.Address              := System.Null_Address;
   end record;

   type Server_Session is limited record
      Component : System.Address              := System.Null_Address;
      Write     : System.Address              := System.Null_Address;
      Index     : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
   end record;

   type Dispatcher_Capability is limited record
      Session : System.Address;
   end record;

end Gneiss_Internal.Log;
