
package body Cai.Log with
   SPARK_Mode
is

   function Image (V : Integer) return String
   is
   begin
      return Image (Long_Integer (V));
   end Image;

   function Image (V : Long_Integer) return String
   is
      Img : String (1 .. 20) := (others => '_');
      T : Long_Integer := V;
   begin
      for I in reverse Img'First + 1 .. Img'Last loop
         Img (I) := Character'Val (48 + abs(T rem 10));
         T := T / 10;
         if T = 0 then
            if V < 0 then
               Img (I - 1) := '-';
               return R : constant String (1 .. Img'Last - I + 2) := Img (I - 1 .. Img'Last) do
                  null;
               end return;
            else
               return R : constant String (1 .. Img'Last - I + 1) := Img (I .. Img'Last) do
                  null;
               end return;
            end if;
         end if;
      end loop;
      return Img;
   end Image;

   function Image (V : Boolean) return String
   is
   begin
      if V then
         return "True";
      else
         return "False";
      end if;
   end Image;

   function Image (V : Unsigned) return String
   is
      Img : String (1 .. 16) := (others => '0');
      T : Unsigned := V;
      type U8 is mod 2 ** 8;
      TU : U8;
      function Hex (U : U8) return Character is
         (if U < 10 then Character'Val (U + 48) else Character'Val (U + 55));
      S : Integer := Img'Last;
   begin
      for I in reverse Integer range 1 .. 8 loop
         TU := U8 (T and 16#ff#);
         Img (I * 2) := Hex (TU and 16#0f#);
         Img (I * 2 - 1) := Hex (TU / 16);
         T := T / 256;
         exit when T = 0;
      end loop;
      for I in Img'Range loop
         if Img (I) /= '0' then
            S := I;
            exit;
         end if;
      end loop;
      return R : constant String (1 .. Img'Last - S + 1) := Img (S .. Img'last) do
         null;
      end return;
   end Image;

   function Image (V : Duration) return String
   is
      Seconds : constant Integer := Integer (V - 0.5);
      Frac : Integer := Integer ((V - Duration (Seconds)) * 1000000);
      Simg : constant String := Image (Seconds);
      Fimg : String (1 .. 6) := (others => '0');
   begin
      for I in reverse Fimg'Range loop
         Fimg (I) := Character'Val (48 + abs(Frac rem 10));
         Frac := Frac / 10;
      end loop;
      return Simg & "." & Fimg;
   end Image;

end Cai.Log;
