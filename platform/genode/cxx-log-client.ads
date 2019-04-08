
with Cai.Types;
with Cxx.Genode;

package Cxx.Log.Client
   with SPARK_Mode => On
is

   procedure Initialize (This  : in out Cxx.Void_Address;
                         Cap   :        Cai.Types.Capability;
                         Label :        Cxx.Void_Address;
                         Size  :        Cxx.Genode.Uint64_T) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_log_client_initialize";

   procedure Finalize (This : in out Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_log_client_finalize";

   procedure Write (This    : Cxx.Void_Address;
                    Message : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_log_client_write";

   procedure Flush (This : Cxx.Void_Address) with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_log_client_flush";

   function Maximal_Message_Length (This : Cxx.Void_Address) return Cxx.Genode.Uint64_T with
      Global        => null,
      Import,
      Convention    => CPP,
      External_Name => "cai_log_client_maximal_message_length";

end Cxx.Log.Client;
