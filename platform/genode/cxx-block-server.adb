with System;

package body Cxx.Block.Server with
   SPARK_Mode => Off
is

   function Writable (This : Class) return Cxx.Bool
   is
      function Writable (S : System.Address) return Boolean with
         Import,
         Address => This.Writable;
   begin
      return (if Writable (Cxx.Block.Server.Get_Instance (This))
              then Cxx.Bool'Val (1)
              else Cxx.Bool'Val (0));
   end Writable;

end Cxx.Block.Server;
