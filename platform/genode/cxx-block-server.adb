with System;

package body Cxx.Block.Server with
   SPARK_Mode => Off
is

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
