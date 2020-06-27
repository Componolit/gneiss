package body Gneiss_Internal.Stream_Session with
   SPARK_Mode
is

   procedure Read (Fd     :     File_Descriptor;
                   Data   : out Buffer;
                   Length : out Natural) with
      SPARK_Mode => Off
   is
   begin
      Length := Data'Length;
      Read (Fd, Data'Address, Length);
   end Read;

   procedure Write (Fd     :     File_Descriptor;
                    Data   :     Buffer;
                    Length : out Natural) with
      SPARK_Mode => Off
   is
   begin
      Length := Data'Length;
      Write (Fd, Data'Address, Length);
   end Write;

end Gneiss_Internal.Stream_Session;
