
private with Cai.Internal.Log;

package Cai.Log with
   SPARK_Mode
is

   type Unsigned is mod 2 ** 64;

   function Image (V : Integer) return String with
      Post => Image'Result'Length <= 20 and Image'Result'First = 1;
   function Image (V : Long_Integer) return String with
      Post => Image'Result'Length <= 20 and Image'Result'First = 1;
   function Image (V : Boolean) return String with
      Post => Image'Result'Length <= 5 and Image'Result'First = 1;
   function Image (V : Unsigned) return String with
      Post => Image'Result'Length <= 16 and Image'Result'First = 1;
   function Image (V : Duration) return String with
      Post => Image'Result'Length <= 27 and Image'Result'First = 1;

   type Client_Session is private;

private

   type Client_Session is new Cai.Internal.Log.Client_Session;

end Cai.Log;
