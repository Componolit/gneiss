private with System;

generic
   type Index is range <>;
   type Element is (<>);
   type Buffer is array (Index range <>) of Element;
package Gneiss_Internal.Stream_Session with
   SPARK_Mode
is

   procedure Read (Fd     :     File_Descriptor;
                   Data   : out Buffer;
                   Length : out Natural) with
      Pre    => Valid (Fd),
      Global => (In_Out => Platform_State);

   procedure Write (Fd     :     File_Descriptor;
                    Data   :     Buffer;
                    Length : out Natural) with
      Pre    => Valid (Fd),
      Global => (In_Out => Platform_State);

   procedure Drop (Fd     : File_Descriptor;
                   Length : Natural) with
      Pre           => Valid (Fd),
      Import,
      Convention    => C,
      External_Name => "gneiss_stream_drop",
      Global        => (In_Out => Platform_State);

private

   procedure Read (Fd     :        File_Descriptor;
                   Data   :        System.Address;
                   Length : in out Natural) with
      Import,
      Convention    => C,
      External_Name => "gneiss_stream_read",
      Global        => (In_Out => Platform_State);

   procedure Write (Fd     :        File_Descriptor;
                    Data   :        System.Address;
                    Length : in out Natural) with
      Import,
      Convention    => C,
      External_Name => "gneiss_stream_write",
      Global        => (In_Out => Platform_State);

end Gneiss_Internal.Stream_Session;
