
generic
   type State is limited private;
   with procedure Event (S : in out State);
   with function Block_Count (S : State) return Count;
   with function Block_Size (S : State) return Size;
   with function Writable (S : State) return Boolean;
   with function Maximal_Transfer_Size (S : State) return Unsigned_Long;
   with procedure Initialize (S : in out Server_Session; L : String; C : in out State);
   with procedure Finalize (S : in out Server_Session);
package Cai.Block.Server is

   type Request is new Block.Request;

   function Create return Server_Session;

   function Initialized (S : Server_Session) return Boolean;

   procedure Next_Request (S : in out Server_Session; R : out Request);

   procedure Read (S : in out Server_Session; R : Request; B : Buffer; Success : out Boolean);

   procedure Write (S : in out Server_Session; R : Request; B : out Buffer; Success : out Boolean);

   procedure Acknowledge (S : in out Server_Session; R : in out Request);

end Cai.Block.Server;
