
with Gneiss.Message;

package body Gneiss.Log with
   SPARK_Mode
is

   function Initialized (C : Client_Session) return Boolean is
      (Gneiss.Message.Initialized (C.Session));

end Gneiss.Log;
