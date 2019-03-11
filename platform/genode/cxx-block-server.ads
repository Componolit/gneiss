package Cxx.Block.Server
   with SPARK_Mode => On
is
   type Class is
   limited record
      Session : Cxx.Void_Address;
      State : Cxx.Void_Address;
      Callback : Cxx.Void_Address;
      Block_Count : Cxx.Void_Address;
      Block_Size : Cxx.Void_Address;
      Writable : Cxx.Void_Address;
   end record
   with Import, Convention => CPP;

   function Default_Constructor return Class
   with Global => null;
   pragma Cpp_Constructor (Default_Constructor, "_ZN3Cai5Block6ServerC1Ev");

   procedure Initialize (This : Class;
                         Label : Cxx.Void_Address;
                         Length : Cxx.Genode.Uint64_T;
                         Callback : Cxx.Void_Address;
                         Block_Count : Cxx.Void_Address;
                         Block_Size : Cxx.Void_Address;
                         Maximal_Transfer_Size : Cxx.Void_Address;
                         Writable : Cxx.Void_Address)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block6Server10initializeEPKcyPvS4_S4_S4_S4_S4_";

   procedure Finalize (This : Class)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block6Server8finalizeEv";

   function Writable (This : Class) return Cxx.Bool
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block6Server8writableEv";

   procedure Next_Request (This : Class; Request : out Cxx.Block.Request.Class)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block6Server12next_requestEPNS0_7RequestE";

   procedure Read (This : Class; Request : Cxx.Block.Request.Class; Buffer : Cxx.Void_Address; Size : Cxx.Genode.Uint64_T; Success : out Cxx.Bool)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block6Server4readENS0_7RequestEPvyPb";

   procedure Write (This : Class; Request : Cxx.Block.Request.Class; Buffer : Cxx.Void_Address; Size : Cxx.Genode.Uint64_T; Success : out Cxx.Bool)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block6Server5writeENS0_7RequestEPvyPb";

   procedure Acknowledge (This : Class; Request : in out Cxx.Block.Request.Class)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block6Server11acknowledgeERNS0_7RequestE";

end Cxx.Block.Server;
