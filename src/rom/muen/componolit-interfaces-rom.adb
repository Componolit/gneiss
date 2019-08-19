
with Musinfo;

package body Componolit.Interfaces.Rom with
   SPARK_Mode
is

   use type Musinfo.Memregion_Type;

   function Create return Client_Session is
      (Client_Session'(Mem => Musinfo.Null_Memregion));

   function Initialized (C : Client_Session) return Boolean is
      (C.Mem /= Musinfo.Null_Memregion);

end Componolit.Interfaces.Rom;
