
with Componolit.Gneiss.Message;

package body Componolit.Gneiss.Log with
   SPARK_Mode
is

   function Initialized (C : Client_Session) return Boolean is
      (Componolit.Gneiss.Message.Initialized (C.Session));

   function Maximum_Message_Length (C : Client_Session) return Integer is
      (C.Buffer'Length);

end Componolit.Gneiss.Log;
