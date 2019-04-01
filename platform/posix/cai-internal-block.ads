
with System;

package Cai.Internal.Block is

   type Private_Data is new Integer;
   Null_Data : Private_Data := 0;
   type Client_Session is limited record
      Instance : System.Address;
   end record;
   type Dispatcher_Session is limited record
      Instance : System.Address;
   end record;
   type Server_Session is limited record
      Instance : System.Address;
   end record;
   type Client_Instance is new System.Address;
   type Dispatcher_Instance is new System.Address;
   type Server_Instance is new System.Address;

end Cai.Internal.Block;
