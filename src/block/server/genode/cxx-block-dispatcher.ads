with Cxx.Block.Server;
with Cxx.Genode;
with Gneiss.Types;

package Cxx.Block.Dispatcher
   with SPARK_Mode => On
is

   type Class is
   limited record
      Root    : Cxx.Void_Address;
      Handler : Cxx.Void_Address;
      Tag     : Cxx.Genode.Uint32_T;
   end record
   with Import, Convention => CPP;

   type Dispatcher_Capability is limited record
      Size  : Cxx.Unsigned_Long;
      Label : Cxx.Void_Address;
      Root  : Cxx.Void_Address;
      Cap   : Cxx.Void_Address;
   end record
   with Import, Convention => CPP;

   type Class_Array is array (Natural range <>) of Class;

   function Constructor return Class with
      Global => null;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai5Block10DispatcherC1Ev");

   procedure Initialize (This     : Class;
                         Cap      : Gneiss.Types.Capability;
                         Callback : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher10initializeEPvS2_";

   procedure Finalize (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher8finalizeEv";

   procedure Announce (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher8announceEv";

   procedure Dispatch (This : Class;
                       Cap  : Dispatcher_Capability) with
      Global        => null,
      Export,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher8dispatchEPv";

   function Label_Content (This : Class;
                           Cap  : Dispatcher_Capability) return Cxx.Void_Address with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher13label_contentEPv";

   function Label_Length (This : Class;
                          Cap  : Dispatcher_Capability) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher12label_lengthEPv";

   function Session_Size (This : Class;
                          Cap  : Dispatcher_Capability) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher12session_sizeEPv";

   procedure Session_Accept (This    :        Class;
                             Cap     :        Dispatcher_Capability;
                             Session : in out Cxx.Block.Server.Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher14session_acceptEPvS2_";

   function Session_Cleanup (This    : Class;
                             Cap     : Dispatcher_Capability;
                             Session : Cxx.Block.Server.Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher15session_cleanupEPvS2_";

   function Get_Capability (This : Class) return Gneiss.Types.Capability with
      Global => null,
      Import,
      Convention => CPP,
      External_Name => "_ZN3Cai5Block10Dispatcher14get_capabilityEv";

end Cxx.Block.Dispatcher;
