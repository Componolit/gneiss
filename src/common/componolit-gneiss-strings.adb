pragma Ada_2012;
package body Componolit.Gneiss.Strings with
   SPARK_Mode
is

   -----------
   -- Image --
   -----------

   function Image (V : Boolean) return String
   is
   begin
      if V then
         return "True";
      else
         return "False";
      end if;
   end Image;

   -----------
   -- Image --
   -----------

   function Image (V : Duration) return String
   is
      Seconds : Long_Integer;
      Frac    : Duration;
      V2      : Duration;
   begin
      V2 := V;
      if V > 9223372036.0 then
         V2 := 9223372036.0;
      end if;
      if V < -9223372036.0 then
         V2 := -9223372036.0;
      end if;
      if V2 = 0.0 then
         Seconds := 0;
      elsif V2 < 0.0 then
         Seconds := Long_Integer (V2 + 0.5);
      else --  V2 > 0.0
         Seconds := Long_Integer (V2 - 0.5);
      end if;
      Frac := abs (V2 - Duration (Seconds));
      Frac := Frac * 1000000 - 0.5;
      --  FIXME: Calls of Image with explicit default parameters
      --  Componolit/Workarounds#2
      declare
         F_Image : constant String          := Image (Long_Integer (Frac), 10, True);
         Pad     : constant String (1 .. 6) := (others => '0');
      begin
         if Frac = -0.5 then
            return Image (Seconds, 10, True) & "." & Pad;
         end if;
         if F_Image'Length >= 6 then
            return Image (Seconds, 10, True) & "." & F_Image (1 .. 6);
         else --  F_Image'Length < 6
            return Image (Seconds, 10, True) & "." & Pad (1 .. 6 - F_Image'Length) & F_Image;
         end if;
      end;
   end Image;

end Componolit.Gneiss.Strings;
