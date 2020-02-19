
with System;

package Gneiss_Internal.Message_Syscall with
   SPARK_Mode
is

   procedure Write (Fd   : Integer;
                    Msg  : System.Address;
                    Size : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_write";

   procedure Read (Fd   : Integer;
                   Msg  : System.Address;
                   Size : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_read";

   function Peek (Fd   : Integer) return Integer with
      Import,
      Convention    => C,
      External_Name => "gneiss_message_peek";

end Gneiss_Internal.Message_Syscall;
