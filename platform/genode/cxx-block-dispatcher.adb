with System;

package body Cxx.Block.Dispatcher is

   procedure Dispatch (This : Class;
                       Label : Cxx.Void_Address;
                       Length : Cxx.Genode.Uint64_T;
                       Session : in out Cxx.Void_Address)
   is
      procedure D (S : System.Address; L : String; I : in out System.Address)
         with
         Import,
         Address => This.Handler;
      Label_String : String (1 .. Integer (Length))
      with Address => Label;
   begin
      D (This.State, Label_String, Session);
   end Dispatch;

end Cxx.Block.Dispatcher;

