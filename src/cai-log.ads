package Cai.Log is

   type Unsigned is mod 2 ** 64;

   function Image (V : Integer) return String;
   function Image (V : Long_Integer) return String;
   function Image (V : Boolean) return String;
   function Image (V : Unsigned) return String;

end Cai.Log;
