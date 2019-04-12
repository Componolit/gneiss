
with System;
with C;

package Cai.Internal.Block is

   type Private_Data is new C.Uint8_T_Array (1 .. 16);
   Null_Data : Private_Data := (others => 0);
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
   Null_Client : constant Client_Instance := Client_Instance (System.Null_Address);
   type Dispatcher_Instance is new System.Address;
   Null_Dispatcher : constant Dispatcher_Instance := Dispatcher_Instance (System.Null_Address);
   type Server_Instance is new System.Address;
   Null_Server : constant Server_Instance := Server_Instance (System.Null_Address);

end Cai.Internal.Block;
