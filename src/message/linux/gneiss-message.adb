
with Gneiss.Platform;

package body Gneiss.Message with
   SPARK_Mode
is

   function Initialized (W : Writer_Session) return Boolean is
      (Gneiss.Platform.Valid_Resource_Descriptor (W.Resource));

   function Initialized (R : Reader_Session) return Boolean is
      (Gneiss.Platform.Valid_Resource_Descriptor (R.Resource));

end Gneiss.Message;
