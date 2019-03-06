package Cxx.Block.Server
   with SPARK_Mode => On
is
   type Class is
   limited record
      Session : Cxx.Void_Address;
      State : Cxx.Void_Address;
   end record
   with Import, Convention => CPP;

   function Default_Constructor return Class
   with Global => null;
   pragma Cpp_Constructor (Default_Constructor, "_ZN3Cai5Block6ServerC1Ev");

   function Constructor (Session : Cxx.Void_Address; State : Cxx.Void_Address) return Class
   with Global => null;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai5Block6ServerC1EPvS1_");

   procedure Initialize (This : Class; Label : Cxx.Void_Address; Length : Cxx.Genode.Uint64_T)
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server10initializeEPKcy";

   procedure Finalize (This : Class)
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server8finalizeEv";

   function Block_Count (This : Class) return Cxx.Genode.Uint64_T
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server11block_countEv";

   function Block_Size (This : Class) return Cxx.Genode.Uint64_T
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server10block_sizeEv";

   function Writable (This : Class) return Cxx.Bool
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server8writableEv";

   function Maximal_Transfer_Size (This : Class) return Cxx.Genode.Uint64_T
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server21maximal_transfer_sizeEv";

   procedure Read (This : Class; Buffer : Cxx.Void_Address; Size : Cxx.Genode.Uint64_T; Req : in out Cxx.Block.Request.Class)
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server4readEPhyRNS0_7RequestE";

   procedure Sync (This : Class; Req : in out Cxx.Block.Request.Class)
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server4syncERNS0_7RequestE";

   procedure Write (This : Class; Buffer : Cxx.Void_Address; Size : Cxx.Genode.Uint64_T; Req : in out Cxx.Block.Request.Class)
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server5writeEPhyRNS0_7RequestE";

   procedure Acknowledge (This : Class; Req : in out Cxx.Block.Request.Class)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block6Server11acknowledgeERNS0_7RequestE";

   function State_Size return Cxx.Genode.Uint64_T
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server10state_sizeEv";

end Cxx.Block.Server;
