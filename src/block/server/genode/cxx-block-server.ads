with Componolit.Gneiss.Types;
with Cxx.Genode;

package Cxx.Block.Server
   with SPARK_Mode => On
is
   type Class is
   limited record
      Session               : Cxx.Void_Address;
      Callback              : Cxx.Void_Address;
      Block_Count           : Cxx.Void_Address;
      Block_Size            : Cxx.Void_Address;
      Writable              : Cxx.Void_Address;
      Tag                   : Cxx.Genode.Uint32_T;
   end record
   with Import, Convention => CPP;

   type Request is limited record
      Kind         : Integer;
      Block_Number : Cxx.Genode.Uint64_T;
      Block_Count  : Cxx.Unsigned_Long;
      Success      : Cxx.Bool;
      Offset       : Cxx.Long;
      Tag          : Cxx.Unsigned_Long;
   end record;

   function Constructor return Class with
      Global => null;
   pragma Cpp_Constructor (Constructor, "_ZN3Cai5Block6ServerC1Ev");

   function Get_Instance (This : Class) return Cxx.Void_Address with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server12get_instanceEv";

   procedure Initialize (This                  : Class;
                         Cap                   : Componolit.Gneiss.Types.Capability;
                         Size                  : Cxx.Genode.Uint64_T;
                         Callback              : Cxx.Void_Address;
                         Block_Count           : Cxx.Void_Address;
                         Block_Size            : Cxx.Void_Address;
                         Writable              : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server10initializeEPvyS2_S2_S2_S2_";

   procedure Finalize (This : Class) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server8finalizeEv";

   procedure Process_Request (This :        Class;
                              Req  : in out Request;
                              Suc  :    out Integer) with
      Global => null,
      Import,
      Convention => CPP,
      External_Name => "_ZN3Cai5Block6Server15process_requestEPvPi";

   procedure Read (This   : Class;
                   Req    : Request;
                   Buffer : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server4readEPvS2_";

   procedure Write (This   : Class;
                    Req    : Request;
                    Buffer : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server5writeEPvS2_";

   procedure Read_Write (This   : Class;
                         Req    : Request;
                         Id     : Cxx.Genode.Uint32_T;
                         Buffer : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server10read_writeEPvjPFvS2_jS2_yE";

   procedure Acknowledge (This   :        Class;
                          Req    : in out Request;
                          Status : in out Integer) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "_ZN3Cai5Block6Server11acknowledgeEPvPi";

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
