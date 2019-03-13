
package body Cxx.Block.Dispatcher is

   procedure Dispatch (This : Class)
   is
      procedure D
         with
         Import,
         Address => This.Handler;
   begin
      D;
   end Dispatch;

end Cxx.Block.Dispatcher;

