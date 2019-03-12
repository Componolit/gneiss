with Cxx.Block.Server;

package Cxx.Block.Dispatcher
   with SPARK_Mode => On
is

   type Class is
   limited record
      Root : Cxx.Void_Address;
      Handler : Cxx.Void_Address;
      State : Cxx.Void_Address;
   end record
   with Import, Convention => CPP;

   type Class_Address is private;
   type Class_Array is array (Natural range <>) of Class;
   type Class_Address_Array is array (Natural range <>) of Class_Address;

   function Constructor return Class
   with Global => null;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai5Block10DispatcherC1Ev");

   procedure Initialize (This : Class; Callback : Cxx.Void_Address; State : Cxx.Void_Address)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher10initializeEPvS2_";

   procedure Finalize (This : Class)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher8finalizeEv";

   procedure Announce (This : Class)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher8announceEv";

   procedure Dispatch (This : Class)
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher8dispatchEv";

   function Label_Content (This : Class) return Cxx.Void_Address
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher13label_contentEv";

   function Label_Length (This : Class) return Cxx.Genode.Uint64_T
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher12label_lengthEv";

   function Session_Size (This : Class) return Cxx.Genode.Uint64_T
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher12session_sizeEv";

   procedure Session_Accept (This : Class; Session : in out Cxx.Block.Server.Class)
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher14session_acceptEPv";

   function Session_Cleanup (This : Class; Session : Cxx.Block.Server.Class) return Cxx.Bool
   with Global => null, Import, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher15session_cleanupEPv";

private
   pragma SPARK_Mode (Off);

   type Class_Address is access Class;
end Cxx.Block.Dispatcher;
