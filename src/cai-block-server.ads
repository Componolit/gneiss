with Cai.Component;

generic
   with procedure Acknowledge (D : in out Component.Block_Server_Device; R : Request; C : Context);
package Cai.Block.Server is

   procedure Initialize (D : out Component.Block_Server_Device; L : String; C : Context);

   procedure Finalize (D : in out Component.Block_Server_Device);

   function Block_Count (D : Component.Block_Server_Device) return Count;

   function Block_Size (D : Component.Block_Server_Device) return Size;

   function Writable (D : Component.Block_Server_Device) return Boolean;

   function Maximal_Transfer_Size (D : Component.Block_Server_Device) return Unsigned_Long;

   procedure Read (D : in out Component.Block_Server_Device; B : out Buffer; R : in out Request);

   procedure Write (D : in out Component.Block_Server_Device; B : Buffer; R : in out Request);

   procedure Sync (D : in out Component.Block_Server_Device);

end Cai.Block.Server;
