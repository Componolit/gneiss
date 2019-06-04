with Componolit.Interfaces.Types;

package Cxx.Block.Client
   with SPARK_Mode => On
is
   type Private_Uint64_T is limited private;
   type Private_Uint64_T_Address is limited private;
   type Private_Uint64_T_Array is array (Natural range <>) of Private_Uint64_T;
   type Private_Uint64_T_Address_Array is array (Natural range <>) of Private_Uint64_T_Address;
   type Private_Void is limited private;

   type Class is
   limited record
      Private_X_Block_Count : Private_Uint64_T;
      Private_X_Block_Size  : Private_Uint64_T;
      Private_X_Buffer_Size : Private_Uint64_T;
      Private_X_Device      : Private_Void;
      Private_X_Callback    : Private_Void;
      Private_X_Write       : Private_Void;
      Private_X_Env         : Private_Void;
   end record
   with Import, Convention => CPP;

   type Class_Address is private;
   type Class_Array is array (Natural range <>) of Class;
   type Class_Address_Array is array (Natural range <>) of Class_Address;

   function Constructor return Class with
      Global => null;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai5Block6ClientC1Ev");

   function Get_Instance (This : Class) return Cxx.Void_Address with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client12get_instanceEv";

   function Initialized (This : Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client11initializedEv";

   procedure Initialize (This        : Class;
                         Cap         : Componolit.Interfaces.Types.Capability;
                         Device      : Cxx.Char_Array;
                         Callback    : Cxx.Void_Address;
                         Rw          : Cxx.Void_Address;
                         Buffer_Size : Cxx.Genode.Uint64_T) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client10initializeEPvPKcS2_S2_y";

   procedure Finalize (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client8finalizeEv";

   function Ready (This : Class;
                   Req  : Cxx.Block.Request.Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client5readyENS0_7RequestE";

   function Supported (This : Class;
                       Req  : Cxx.Block.Kind) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client9supportedENS0_4KindE";

   procedure Enqueue (This : Class;
                      Req  : Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client7enqueueENS0_7RequestE";

   procedure Submit (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client6submitEv";

   function Next (This : Class) return Cxx.Block.Request.Class with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client4nextEv";

   procedure Read (This :        Class;
                   Req  :        Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client4readENS0_7RequestE";

   procedure Release (This : Class;
                      Req  : Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client7releaseENS0_7RequestE";

   function Writable (This : Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client8writableEv";

   function Block_Count (This : Class) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client11block_countEv";

   function Block_Size (This : Class) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client10block_sizeEv";

   function Maximum_Transfer_Size (This : Class) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client21maximum_transfer_sizeEv";

private
   pragma SPARK_Mode (Off);

   type Class_Address is access Class;
   type Private_Uint64_T is new Cxx.Genode.Uint64_T;
   type Private_Uint64_T_Address is access Private_Uint64_T;
   type Private_Void is new Cxx.Void;
end Cxx.Block.Client;
