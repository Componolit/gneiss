
with Interfaces;

package body Componolit.Interfaces.Strings_Generic with
   SPARK_Mode
is
   package SI renames Standard.Interfaces;
   use type SI.Unsigned_8;
   use type SI.Unsigned_64;

   function Hex (U : SI.Unsigned_8;
                 C : Boolean) return Character
   is
      (if
          U < 10
       then
          Character'Val (U + 48)
       else
          (if C then Character'Val (U + 55) else Character'Val (U + 87))) with
      Pre => U <= 16;

   function Image_Ranged (V : I;
                          B : Base    := 10;
                          C : Boolean := True) return String
   is
      function Image_Unsigned is new Image_Modular (SI.Unsigned_64);
      L : constant Long_Integer := Long_Integer (V);
      U : SI.Unsigned_64;
   begin
      if L = Long_Integer'First then
         U := SI.Unsigned_64 (abs (L + 1)) + 1;
      else
         U := SI.Unsigned_64 (abs (L));
      end if;
      if V >= 0 then
         return Image_Unsigned (U, B, C);
      else
         return "-" & Image_Unsigned (U, B, C);
      end if;
   end Image_Ranged;

   function Image_Modular (V : U;
                           B : Base    := 10;
                           C : Boolean := True) return String
   is
      Image : String (1 .. Base_Length (B)) := (others => '_');
      T     : SI.Unsigned_64                := SI.Unsigned_64 (V);
   begin
      for I in reverse Image'First .. Image'Last loop
         Image (I) := Hex (SI.Unsigned_8 (T rem SI.Unsigned_64 (B)), C);
         T       := T / SI.Unsigned_64 (B);
         if T = 0 then
            return
               R : constant String (1 .. Image'Last - I + 1) := Image (I .. Image'Last)
            do
               null;
            end return;
         end if;
      end loop;
      return Image;
   end Image_Modular;

end Componolit.Interfaces.Strings_Generic;
