
with Componolit.Interfaces.Internal.Block;

package body Cxx.Block.Dispatcher
is

   procedure Dispatch (This : Class;
                       Cap  : Dispatcher_Capability)
   is
      procedure D (I : Componolit.Interfaces.Internal.Block.Dispatcher_Instance;
                   C : Dispatcher_Capability) with
         Import,
         Address => This.Handler;
   begin
      D (Componolit.Interfaces.Internal.Block.Dispatcher_Instance'(Root    => This.Root,
                                                                   Handler => This.Handler), Cap);
   end Dispatch;

end Cxx.Block.Dispatcher;
