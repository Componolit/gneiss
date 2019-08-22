
with Musinfo;

package body Componolit.Interfaces.Log with
   SPARK_Mode
is

   use type Musinfo.Name_Type;
   use type Musinfo.Memregion_Type;

   function Initialized (C : Client_Session) return Boolean is
      (C.Name /= Musinfo.Null_Name and C.Mem /= Musinfo.Null_Memregion);

   function Maximum_Message_Length (C : Client_Session) return Integer is
      (200);

end Componolit.Interfaces.Log;
