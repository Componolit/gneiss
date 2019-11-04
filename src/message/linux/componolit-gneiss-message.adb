
package body Componolit.Gneiss.Message with
   SPARK_Mode
is

   function Initialized (C : Client_Session) return Boolean is
      (C.File_Descriptor >= 0);

end Componolit.Gneiss.Message;
