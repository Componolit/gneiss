with System;
with Cxx.Genode;
use all type Cxx.Genode.Uint64_T;

package body Cxx.Block.Server is

   function Writable (This : Class) return Cxx.Bool
   is
      function Writable (S : System.Address) return Boolean
         with
         Import,
         Address => This.Writable;
   begin
      return (if Writable (Cxx.Block.Server.Get_Instance (This)) then 1 else 0);
   end Writable;

end Cxx.Block.Server;
