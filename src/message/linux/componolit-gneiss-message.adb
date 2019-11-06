
with Componolit.Gneiss.Platform;

package body Componolit.Gneiss.Message with
   SPARK_Mode
is

   function Initialized (W : Writer_Session) return Boolean is
      (Componolit.Gneiss.Platform.Valid_Resource_Descriptor (W.Resource));

   function Initialized (R : Reader_Session) return Boolean is
      (Componolit.Gneiss.Platform.Valid_Resource_Descriptor (R.Resource));

end Componolit.Gneiss.Message;
