
private with Cai.Internal.Log;

package Cai.Log with
   SPARK_Mode
is

   type Unsigned is mod 2 ** 64;

   function Image (V : Integer) return String with
      Post => Image'Result'Length <= 20;
   function Image (V : Long_Integer) return String with
      Post => Image'Result'Length <= 20;
   function Image (V : Boolean) return String with
      Post => Image'Result'Length <= 5;
   function Image (V : Unsigned) return String with
      Post => Image'Result'Length <= 16;
   function Image (V : Duration) return String with
      Pre => Long_Integer (V) < 9223
             and Long_Integer (V) > -9223,
      Post => Image'Result'Length <= 20;

   type Client_Session is limited private;

private

   type Client_Session is new Cai.Internal.Log.Client_Session;

end Cai.Log;
