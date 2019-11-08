with Componolit.Gneiss.Types;
with Cxx.Genode;

package Cxx.Block.Client
   with SPARK_Mode => On
is
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
      Block_Count : Cxx.Genode.Uint64_T;
      Block_Size  : Cxx.Genode.Uint64_T;
      Device      : Cxx.Void_Address;
      Callback    : Cxx.Void_Address;
      Write       : Cxx.Void_Address;
      Env         : Cxx.Void_Address;
      Tag         : Cxx.Genode.Uint32_T;
   end record
   with Import, Convention => CPP;

   function Constructor return Class with
      Global => null;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai5Block6ClientC1Ev");

   function Initialized (This : Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client11initializedEv";

   procedure Initialize (This        : Class;
                         Cap         : Componolit.Gneiss.Types.Capability;
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
                               Tag    :        Cxx.Unsigned_Long;
                               Oom    :    out Integer) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client16allocate_requestEPviymmPi";

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

   procedure Read_Write (This :        Class;
                         Req  :        Packet_Descriptor) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Client10read_writeEPv";

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

end Cxx.Block.Client;
