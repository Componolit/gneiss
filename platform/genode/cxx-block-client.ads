with Cai.Types;

package Cxx.Block.Client
   with SPARK_Mode => On
is

   procedure Initialize (This        : in out Cxx.Void_Address;
                         Cap         :        Cai.Types.Capability;
                         Device      :        Cxx.Char_Array;
                         Callback    :        Cxx.Void_Address;
                         Buffer_Size :        Cxx.Genode.Uint64_T) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_initialize";

   procedure Finalize (This : in out Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_finalize";

   function Ready (This : Cxx.Void_Address;
                   Req  : Cxx.Block.Request.Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_ready";

   function Supported (This : Cxx.Void_Address;
                       Req  : Cxx.Block.Request.Class) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_supported";

   procedure Enqueue_Read (This : Cxx.Void_Address;
                           Req  : Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_enqueue_read";

   procedure Enqueue_Write (This :        Cxx.Void_Address;
                            Req  :        Cxx.Block.Request.Class;
                            Data : in out Cxx.Genode.Uint8_T_Array) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_enqueue_write";

   procedure Enqueue_Sync (This : Cxx.Void_Address;
                           Req  : Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_enqueue_sync";

   procedure Enqueue_Trim (This : Cxx.Void_Address;
                           Req  : Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_enqueue_trim";

   procedure Submit (This : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_submit";

   function Next (This : Cxx.Void_Address) return Cxx.Block.Request.Class with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_next";

   procedure Read (This :        Cxx.Void_Address;
                   Req  :        Cxx.Block.Request.Class;
                   Data : in out Cxx.Genode.Uint8_T_Array) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_read";

   procedure Release (This : Cxx.Void_Address;
                      Req  : Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_release";

   function Writable (This : Cxx.Void_Address) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_writable";

   function Block_Count (This : Cxx.Void_Address) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_block_count";

   function Block_Size (This : Cxx.Void_Address) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_block_size";

   function Maximal_Transfer_Size (This : Cxx.Void_Address) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_client_maximal_transfer_size";

end Cxx.Block.Client;
