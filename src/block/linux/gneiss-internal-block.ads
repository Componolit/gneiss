
with C;
with System;

package Gneiss.Internal.Block is

   type Client_Session is limited record
      Event       : System.Address;
      Rw          : System.Address;
      Fd          : Integer;
      Writable    : Integer;
      Block_Size  : C.Uint64_T;
      Block_Count : C.Uint64_T;
      Tag         : C.Uint32_T;
   end record;

   type Dispatcher_Session is limited record
      Instance : System.Address := System.Null_Address;
   end record;

   type Server_Session is limited record
      Instance : System.Address := System.Null_Address;
   end record;

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
      Kind    : Request_Kind;
      Tag     : C.Uint32_T;
      Start   : C.Uint64_T;
      Length  : C.Uint64_T;
      Status  : Request_Status;
      Aiocb   : System.Address;
      Session : C.Uint32_T;
   end record;

   type Server_Request is null record;

   type Dispatcher_Capability is null record;

end Gneiss.Internal.Block;
