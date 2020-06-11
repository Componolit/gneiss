with System;

package Gneiss_Internal.Packet_Session with
   SPARK_Mode
is

   procedure Gneiss_Packet_Send (Fd   :        File_Descriptor;
                                 Addr :        System.Address;
                                 Size : in out Natural) with
      Pre           => Valid (Fd),
      Import,
      Convention    => C,
      External_Name => "gneiss_packet_send",
      Global        => (In_Out => Platform_State);

   procedure Gneiss_Packet_Receive (Fd   :        File_Descriptor;
                                    Addr :        System.Address;
                                    Size : in out Natural) with
      Pre           => Valid (Fd),
      Import,
      Convention    => C,
      External_Name => "gneiss_packet_receive",
      Global        => (In_Out => Platform_State);

end Gneiss_Internal.Packet_Session;
