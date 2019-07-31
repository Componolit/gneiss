
with C;
with System;

package Componolit.Interfaces.Internal.Block is

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

   type Request_Kind is new C.Uint32_T;
   type Request_Status is new C.Uint32_T;

   None  : constant Request_Kind := 0;
   Read  : constant Request_Kind := 1;
   Write : constant Request_Kind := 2;
   Sync  : constant Request_Kind := 3;
   Trim  : constant Request_Kind := 4;

   Raw          : constant Request_Status := 0;
   Allocated    : constant Request_Status := 1;
   Pending      : constant Request_Status := 2;
   Ok           : constant Request_Status := 3;
   Error        : constant Request_Status := 4;

   type Client_Request is record
      Kind   : Request_Kind;
      Tag    : C.Uint32_T;
      Start  : C.Uint64_T;
      Length : C.Uint64_T;
      Status : Request_Status;
      Aiocb  : System.Address;
      Queue  : System.Address;
   end record;

   type Client_Request_Handle is record
      Tag   : C.Uint32_T;
      Valid : C.Uint32_T;
   end record;

   type Dispatcher_Capability is null record;

end Componolit.Interfaces.Internal.Block;
