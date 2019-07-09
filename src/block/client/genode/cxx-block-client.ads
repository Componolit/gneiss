with Componolit.Interfaces.Types;
with Cxx.Genode;

package Cxx.Block.Client
   with SPARK_Mode => On
is
   type Private_Uint64_T is limited private;
   type Private_Uint64_T_Address is limited private;
   type Private_Uint64_T_Array is array (Natural range <>) of Private_Uint64_T;
   type Private_Uint64_T_Address_Array is array (Natural range <>) of Private_Uint64_T_Address;
   type Private_Void is limited private;

   type Packet_Descriptor is limited record
      Offset       : Cxx.Long;
      Bytes        : Cxx.Unsigned_Long;
      Opcode       : Integer;
      Tag          : Cxx.Unsigned_Long;
      Block_Number : Cxx.Unsigned_Long_Long;
      Block_Count  : Cxx.Unsigned_Long;
   end record;

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

   procedure Allocate_Request (This   :        Class;
                               Req    : in out Packet_Descriptor;
                               Opcode :        Integer;
                               Start  :        Cxx.Genode.Uint64_T;
                               Length :        Cxx.Unsigned_Long;
                               Tag    :        Cxx.Unsigned_Long) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client16allocate_requestEPviymm";

   procedure Update_Response_Queue (This    :     Class;
                                    State   : out Integer;
                                    Tag     : out Cxx.Unsigned_Long;
                                    Success : out Integer) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client21update_response_queueEPiPmS2_";

   procedure Enqueue (This : Class;
                      Req  : in out Packet_Descriptor) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client7enqueueEPv";

   procedure Submit (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client6submitEv";

   procedure Read (This :        Class;
                   Req  :        Packet_Descriptor) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client4readEPv";

   procedure Release (This : Class;
                      Req  : in out Packet_Descriptor) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client7releaseEPv";

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
