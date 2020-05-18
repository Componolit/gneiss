
package Gneiss_Internal.Util with
   SPARK_Mode
is

   generic
      type Buffer_Index is range <>;
   function Get_First (Length : Integer) return Buffer_Index;

   generic
      type Buffer_Index is range <>;
   function Get_Last (Length : Integer) return Buffer_Index;

end Gneiss_Internal.Util;
