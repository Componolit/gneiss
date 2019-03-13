
generic
   with procedure Event;
   with function Block_Count (S : Server_Instance) return Count;
   with function Block_Size (S : Server_Instance) return Size;
   with function Writable (S : Server_Instance) return Boolean;
   with function Maximal_Transfer_Size (S : Server_Instance) return Unsigned_Long;
   with procedure Initialize (S : Server_Instance; L : String);
   with procedure Finalize (S : Server_Instance);
package Cai.Block.Server is

   type Request is new Block.Request;

   function Create return Server_Session;

   function Get_Instance (S : Server_Session) return Server_Instance;

   function Initialized (S : Server_Session) return Boolean;

   function Head (S : Server_Session) return Request;

   procedure Discard (S : in out Server_Session);

   procedure Read (S : in out Server_Session; R : Request; B : Buffer; Success : out Boolean);

   procedure Write (S : in out Server_Session; R : Request; B : out Buffer; Success : out Boolean);

   procedure Acknowledge (S : in out Server_Session; R : in out Request);

end Cai.Block.Server;
