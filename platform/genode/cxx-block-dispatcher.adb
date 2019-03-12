with System;

package body Cxx.Block.Dispatcher is

   procedure Dispatch (This : Class)
   is
      procedure D (S : System.Address; St : System.Address)
         with
         Import,
         Address => This.Handler;
   begin
      D (This.State, This.State);
   end Dispatch;

end Cxx.Block.Dispatcher;

