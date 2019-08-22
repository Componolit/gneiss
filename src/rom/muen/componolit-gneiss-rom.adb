
with Musinfo;

package body Componolit.Gneiss.Rom with
   SPARK_Mode
is

   use type Musinfo.Memregion_Type;

   function Initialized (C : Client_Session) return Boolean is
      (C.Mem /= Musinfo.Null_Memregion);

end Componolit.Gneiss.Rom;
