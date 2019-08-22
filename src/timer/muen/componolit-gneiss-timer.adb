
with Componolit.Gneiss.Muen;

package body Componolit.Gneiss.Timer with
   SPARK_Mode
is
   package CIM renames Componolit.Gneiss.Muen;
   use type CIM.Session_Index;

   function Initialized (C : Client_Session) return Boolean is
      (C.Index /= CIM.Invalid_Index);

end Componolit.Gneiss.Timer;
