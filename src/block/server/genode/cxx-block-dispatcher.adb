
with System;

package body Cxx.Block.Dispatcher
is

   procedure Dispatch (This : Class;
                       Cap  : Dispatcher_Capability)
   is
      procedure D (I : System.Address;
                   C : Dispatcher_Capability) with
         Import,
         Address => This.Handler;
   begin
      D (Get_Instance (This), Cap);
   end Dispatch;

end Cxx.Block.Dispatcher;
