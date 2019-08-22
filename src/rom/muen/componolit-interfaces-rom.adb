
with Musinfo;

package body Componolit.Interfaces.Rom with
   SPARK_Mode
is

   use type Musinfo.Memregion_Type;

   function Initialized (C : Client_Session) return Boolean is
      (C.Mem /= Musinfo.Null_Memregion);

end Componolit.Interfaces.Rom;
