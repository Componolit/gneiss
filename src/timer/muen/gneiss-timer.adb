
with Gneiss.Muen;
with Musinfo.Instance;

package body Gneiss.Timer with
   SPARK_Mode
is
   package CIM renames Gneiss.Muen;
   use type CIM.Session_Id;

   function Initialized (C : Client_Session) return Boolean is
      (Musinfo.Instance.Is_Valid and then C.Index /= CIM.Invalid_Index);

end Gneiss.Timer;
