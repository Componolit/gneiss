
with Gneiss.Types;
with Cxx.Genode;

package Cxx.Log.Client
   with SPARK_Mode => On
is
   type Private_Void is limited private;
   type Private_Void_Address is limited private;
   type Private_Void_Array is array (Natural range <>) of Private_Void;
   type Private_Void_Address_Array is array (Natural range <>) of Private_Void_Address;

   type Class is
   limited record
      Private_Session : Private_Void;
   end record
   with Import, Convention => CPP;

   type Class_Address is private;
   type Class_Array is array (Natural range <>) of Class;
   type Class_Address_Array is array (Natural range <>) of Class_Address;

   function Constructor return Class
   with Global => null;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai3Log6ClientC1Ev");

   function Initialized (This : Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai3Log6Client11initializedEv";

   procedure Initialize (This  : Class;
                         Cap   : Gneiss.Types.Capability;
                         Label : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai3Log6Client10initializeEPvPKc";

   procedure Finalize (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai3Log6Client8finalizeEv";

   procedure Write (This : Class; Message : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai3Log6Client5writeEPKc";

   function Maximum_Message_Length (This : Class) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai3Log6Client22maximum_message_lengthEv";

private
   pragma SPARK_Mode (Off);

   type Class_Address is access Class;
   type Private_Void is new Cxx.Void;
   type Private_Void_Address is access Private_Void;
end Cxx.Log.Client;
