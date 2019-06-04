with Componolit.Interfaces.Types;

package Cxx.Block.Server
   with SPARK_Mode => On
is
   type Class is
   limited record
      Session               : Cxx.Void_Address;
      Callback              : Cxx.Void_Address;
      Block_Count           : Cxx.Void_Address;
      Block_Size            : Cxx.Void_Address;
      Maximum_Transfer_Size : Cxx.Void_Address;
      Writable              : Cxx.Void_Address;
   end record
   with Import, Convention => CPP;

   function Constructor return Class with
      Global => null;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai5Block6ServerC1Ev");

   function Get_Instance (This : Class) return Cxx.Void_Address with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server12get_instanceEv";

   procedure Initialize (This                  : Class;
                         Cap                   : Componolit.Interfaces.Types.Capability;
                         Size                  : Cxx.Genode.Uint64_T;
                         Callback              : Cxx.Void_Address;
                         Block_Count           : Cxx.Void_Address;
                         Block_Size            : Cxx.Void_Address;
                         Maximum_Transfer_Size : Cxx.Void_Address;
                         Writable              : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server10initializeEPvyS2_S2_S2_S2_S2_";

   procedure Finalize (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server8finalizeEv";

   function Writable (This : Class) return Cxx.Bool with
      Global        => null,
      Export,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server8writableEv";

   function Head (This : Class) return Cxx.Block.Request.Class with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server4headEv";

   procedure Discard (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server7discardEv";

   procedure Read (This   : Class;
                   Req    : Cxx.Block.Request.Class;
                   Buffer : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server4readENS0_7RequestEPv";

   procedure Write (This   : Class;
                    Req    : Cxx.Block.Request.Class;
                    Buffer : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server5writeENS0_7RequestEPv";

   procedure Acknowledge (This :        Class;
                          Req  : in out Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server11acknowledgeERNS0_7RequestE";

   function Initialized (This : Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server11initializedEv";

   procedure Unblock_Client (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server14unblock_clientEv";

end Cxx.Block.Server;
