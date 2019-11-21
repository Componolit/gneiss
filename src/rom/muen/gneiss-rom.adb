
with Musinfo;
with Musinfo.Instance;

package body Gneiss.Rom with
   SPARK_Mode
is

   use type Musinfo.Memregion_Type;

   function Initialized (C : Client_Session) return Boolean is
      (Musinfo.Instance.Is_Valid
       and then C.Mem /= Musinfo.Null_Memregion);

end Gneiss.Rom;
