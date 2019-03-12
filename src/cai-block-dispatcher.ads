with Cai.Block.Server;

generic
   type State is limited private;
   with package Server is new Cai.Block.Server (<>);
   with procedure Dispatch (S : in out State; Label : String; I : in out System.Address);
package Cai.Block.Dispatcher
is

   function Create return Dispatcher_Session;

   procedure Initialize (D : in out Dispatcher_Session; C : in out State);

   procedure Register (D : in out Dispatcher_Session);

   procedure Finalize (D : in out Dispatcher_Session);

end Cai.Block.Dispatcher;
