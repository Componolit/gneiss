with System;

package Gneiss_Internal.Packet_Session with
   SPARK_Mode
is

   use type System.Address;

   procedure Gneiss_Packet_Allocate (Addr : out System.Address;
                                     Size :     Natural) with
      Import,
      Convention    => C,
      External_Name => "gneiss_packet_allocate";

   procedure Gneiss_Packet_Free (Addr : in out System.Address) with
      Post          => Addr = System.Null_Address,
      Import,
      Convention    => C,
      External_Name => "gneiss_packet_free";

   procedure Gneiss_Packet_Send (Fd   : File_Descriptor;
                                 Addr : System.Address;
                                 Size : Natural) with
      Pre           => Valid (Fd),
      Import,
      Convention    => C,
      External_Name => "gneiss_packet_send";

   procedure Gneiss_Packet_Receive (Fd   :     File_Descriptor;
                                    Addr : out System.Address;
                                    Size : out Natural) with
      Pre           => Valid (Fd),
      Import,
      Convention    => C,
      External_Name => "gneiss_packet_receive";

end Gneiss_Internal.Packet_Session;
