
package C.Block is

   type Request_Kind is new Uint32_T;
   type Request_Status is new Uint32_T;

   None : constant Request_Kind := 0;
   Read : constant Request_Kind := 1;
   Write : constant Request_Kind := 2;
   Sync : constant Request_Kind := 3;
   Trim : constant Request_Kind := 4;

   Raw : constant Request_Status := 0;
   Ok : constant Request_Status := 1;
   Error : constant Request_Status := 2;
   Acknowledged : constant Request_Status := 3;

   type Request is record
      Kind : Request_Kind;
      Priv : Uint8_T_Array (1 .. 16);
      Start : Uint64_T;
      Length : Uint64_T;
      Status : Request_Status;
   end record;

end C.Block;
