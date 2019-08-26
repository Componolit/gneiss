
with Componolit.Gneiss.Muen;
with Musinfo.Instance;

package body Componolit.Gneiss.Timer with
   SPARK_Mode
is
   package CIM renames Componolit.Gneiss.Muen;
   use type CIM.Session_Index;

   function Initialized (C : Client_Session) return Boolean is
      (Musinfo.Instance.Is_Valid and then C.Index /= CIM.Invalid_Index);

end Componolit.Gneiss.Timer;
