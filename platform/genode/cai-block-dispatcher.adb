
with Cxx.Block.Dispatcher;

package body Cai.Block.Dispatcher
is

   function Create return Dispatcher_Session
   is
   begin
      return Dispatcher_Session' (Instance => Cxx.Block.Dispatcher.Constructor);
   end Create;

   procedure Initialize (D : in out Dispatcher_Session; C : in out State)
   is
   begin
      Cxx.Block.Dispatcher.Initialize (D.Instance, Dispatch'Address, C'Address);
   end Initialize;

   procedure Finalize (D : in out Dispatcher_Session)
   is
   begin
      Cxx.Block.Dispatcher.Finalize (D.Instance);
   end Finalize;

   procedure Register (D : in out Dispatcher_Session) is
   begin
      Cxx.Block.Dispatcher.Announce (D.Instance);
   end Register;

end Cai.Block.Dispatcher;
