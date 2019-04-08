
package Cxx.Block.Dispatcher
   with SPARK_Mode => On
is

   procedure Initialize (This     : in out Cxx.Void_Address;
                         Callback :        Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_block_dispatcher_initialize";

   procedure Finalize (This : in out Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_block_dispatcher_finalize";

   procedure Announce (This : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_block_dispatcher_announce";

   function Label_Content (This : Cxx.Void_Address) return Cxx.Void_Address with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_block_dispatcher_label_content";

   function Label_Length (This : Cxx.Void_Address) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_block_dispatcher_label_length";

   function Session_Size (This : Cxx.Void_Address) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_block_dispatcher_session_size";

   procedure Session_Accept (This    : Cxx.Void_Address;
                             Session : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_block_dispatcher_session_accept";

   function Session_Cleanup (This    : Cxx.Void_Address;
                             Session : Cxx.Void_Address) return Cxx.Bool with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_block_dispatcher_session_cleanup";

end Cxx.Block.Dispatcher;
