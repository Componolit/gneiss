
with Musinfo;

package Gneiss_Internal.Rom with
   SPARK_Mode
is

   type Client_Session is limited record
      Mem : Musinfo.Memregion_Type := Musinfo.Null_Memregion;
   end record;

end Gneiss_Internal.Rom;
