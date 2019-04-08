package Cxx.Block.Server
   with SPARK_Mode => On
is

   procedure Initialize (This                  : in out Cxx.Void_Address;
                         Size                  :        Cxx.Genode.Uint64_T;
                         Callback              :        Cxx.Void_Address;
                         Block_Count           :        Cxx.Void_Address;
                         Block_Size            :        Cxx.Void_Address;
                         Maximal_Transfer_Size :        Cxx.Void_Address;
                         Writable              :        Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_server_initialize";

   procedure Finalize (This : in out Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_server_finalize";

   function Writable (This : Cxx.Void_Address;
                      Writ : Cxx.Void_Address) return Cxx.Bool with
      Global        => null,
      Export,
      Convention    => C,
      External_Name => "cai_block_server_writable";

   function Head (This : Cxx.Void_Address) return Cxx.Block.Request.Class with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_server_head";

   procedure Discard (This : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_server_discard";

   procedure Read (This   : Cxx.Void_Address;
                   Req    : Cxx.Block.Request.Class;
                   Buffer : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_server_read";

   procedure Write (This   : Cxx.Void_Address;
                    Req    : Cxx.Block.Request.Class;
                    Buffer : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_server_write";

   procedure Acknowledge (This :        Cxx.Void_Address;
                          Req  : in out Cxx.Block.Request.Class) with
      Global        => null,
      Import,
      Convention    => C,
      External_Name => "cai_block_server_acknowledge";

end Cxx.Block.Server;
