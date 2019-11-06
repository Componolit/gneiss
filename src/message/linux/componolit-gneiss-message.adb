
package body Componolit.Gneiss.Message with
   SPARK_Mode
is

   function Initialized (W : Writer_Session) return Boolean is
      (W.Resource.Fd >= 0);

end Componolit.Gneiss.Message;
