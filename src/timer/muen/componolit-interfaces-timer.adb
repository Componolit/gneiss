
with Componolit.Interfaces.Muen;

package body Componolit.Interfaces.Timer with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;
   use type CIM.Session_Index;

   function Create return Client_Session is
      (Client_Session'(Index => CIM.Invalid_Index));

   function Initialized (C : Client_Session) return Boolean is
      (C.Index /= CIM.Invalid_Index);

end Componolit.Interfaces.Timer;
