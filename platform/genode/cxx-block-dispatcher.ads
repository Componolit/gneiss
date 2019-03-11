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

   procedure Dispatch (This : Class;
                       Label : Cxx.Void_Address;
                       Length : Cxx.Genode.Uint64_T;
                       Session : in out Cxx.Void_Address)
   with Global => null, Export, Convention => CPP, External_Name => "_ZN3Cai5Block10Dispatcher8dispatchEPKcyPPv";

private
   pragma SPARK_Mode (Off);

   type Class_Address is access Class;
end Cxx.Block.Dispatcher;
