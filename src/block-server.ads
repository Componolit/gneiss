with Component;

generic
   with procedure Acknowledge (D : in out Component.Block_Device; R : Request; C : Context);
package Block.Server is

   procedure Initialize (D : in out Component.Block_Device; L : String; C : Context);

   procedure Finalize (D : in out Component.Block_Device);

   function Block_Count (D : in out Component.Block_Device) return Count;

   functioN Block_Size (D : in out Component.Block_Device) return Size;

   function Writable (D : in out Component.Block_Device) return Boolean;

   function Maximal_Transfer_Size (D : in out Component.Block_Device) return Unsigned_Long;

   procedure Read (D : in out Component.Block_Device; B : out  Buffer; R : in out Request);

   procedure Sync (D : in out Component.Block_Device; R : in out Request);

   procedure Write (D : in out Component.Block_Device; B : Buffer; R : in out Request);

end Block.Server;
