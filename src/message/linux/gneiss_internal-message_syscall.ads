
with System;

package Gneiss_Internal.Message_Syscall with
   SPARK_Mode
is

   procedure Write (Fd   : File_Descriptor;
                    Msg  : System.Address;
                    Size : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_write",
      Global        => (In_Out => Gneiss_Internal.Platform_State);

   procedure Read (Fd   : File_Descriptor;
                   Msg  : System.Address;
                   Size : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_read",
      Global        => (In_Out => Gneiss_Internal.Platform_State);

   function Peek (Fd   : File_Descriptor) return Integer with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_peek",
      Global        => (Input => Gneiss_Internal.Platform_State);

end Gneiss_Internal.Message_Syscall;
