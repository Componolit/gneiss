
with Componolit.Gneiss.Message;

package body Componolit.Gneiss.Log with
   SPARK_Mode
is

   function Initialized (C : Client_Session) return Boolean is
      (Componolit.Gneiss.Message.Initialized (C.Session));

end Componolit.Gneiss.Log;
