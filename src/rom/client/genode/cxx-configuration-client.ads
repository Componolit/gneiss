
with Gneiss.Types;

package Cxx.Configuration.Client with
   SPARK_Mode
is

   type Class is limited record
      Config : Cxx.Void_Address;
   end record
   with Import, Convention => CPP;

   function Constructor return Class;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai13Configuration6ClientC1Ev");

   procedure Initialize (This  : Class;
                         Env   : Gneiss.Types.Capability;
                         Parse : Cxx.Void_Address;
                         Name  : Cxx.Void_Address) with
      Global => null,
      Import,
      Convention => CPP,
      External_Name => "_ZN3Cai13Configuration6Client10initializeEPvS2_PKc";

   function Initialized (This : Class) return Cxx.Bool with
      Global => null,
      Import,
      Convention => CPP,
      External_Name => "_ZN3Cai13Configuration6Client11initializedEv";

   procedure Load (This : Class) with
      Global => null,
      Import,
      Convention => CPP,
      External_Name => "_ZN3Cai13Configuration6Client4loadEv";

   procedure Finalize (This : Class) with
      Global => null,
      Import,
      Convention => CPP,
      External_Name => "_ZN3Cai13Configuration6Client8finalizeEv";

end Cxx.Configuration.Client;
