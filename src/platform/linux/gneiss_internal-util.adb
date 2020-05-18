
package body Gneiss_Internal.Util with
   SPARK_Mode
is

   function Get_First (Length : Integer) return Buffer_Index is
      (if Length < 1 then Buffer_Index'First + 1 else Buffer_Index'First);

   function Get_Last (Length : Integer) return Buffer_Index
   is
   begin
      if Length < 1 then
         return Buffer_Index'First;
      end if;
      if Long_Integer (Length) < Long_Integer (Buffer_Index'Last - Buffer_Index'First + 1) then
         return Buffer_Index (Long_Integer (Buffer_Index'First) + Long_Integer (Length) - 1);
      else
         return Buffer_Index'Last;
      end if;
   end Get_Last;

end Gneiss_Internal.Util;
