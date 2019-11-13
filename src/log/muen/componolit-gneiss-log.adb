
with Musinfo;

package body Componolit.Gneiss.Log with
   SPARK_Mode
is

   use type Musinfo.Name_Type;
   use type Musinfo.Memregion_Type;

   function Initialized (C : Client_Session) return Boolean is
      (C.Name /= Musinfo.Null_Name and C.Mem /= Musinfo.Null_Memregion);

end Componolit.Gneiss.Log;
