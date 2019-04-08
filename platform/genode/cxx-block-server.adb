with System;
with Cxx.Genode;
use all type Cxx.Genode.Uint64_T;

package body Cxx.Block.Server is

   function Writable (This : Cxx.Void_Address;
                      Writ : Cxx.Void_Address) return Cxx.Bool
   is
      function Writable (S : System.Address) return Boolean with
         Import,
         Address => Writ;
   begin
      return (if Writable (This)
              then Cxx.Bool'Val (1)
              else Cxx.Bool'Val (0));
   end Writable;

end Cxx.Block.Server;
