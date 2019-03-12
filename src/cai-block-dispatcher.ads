with Cai.Block.Server;

generic
   with package Server is new Cai.Block.Server (<>);
   with procedure Dispatch (S : in out Server.State);
package Cai.Block.Dispatcher
is

   function Create return Dispatcher_Session;

   procedure Initialize (D : in out Dispatcher_Session; C : in out Server.State);

   procedure Register (D : in out Dispatcher_Session);

   procedure Finalize (D : in out Dispatcher_Session);

   procedure Session_Request (D : in out Dispatcher_Session;
                              Valid : out Boolean;
                              Label : out String;
                              Last : out Natural);

   procedure Session_Accept (D : in out Dispatcher_Session;
                             I : in out Server_Session;
                             L : String;
                             S : in out Server.State);

   procedure Session_Cleanup (D : in out Dispatcher_Session; I : in out Server_Session);

end Cai.Block.Dispatcher;
