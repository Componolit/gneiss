
with Componolit.Gneiss.Platform;

package Componolit.Gneiss.Internal.Message with
   SPARK_Mode
is

   type Writer_Session is limited record
      Resource : Componolit.Gneiss.Platform.Resource_Descriptor :=
         Componolit.Gneiss.Platform.Invalid_Resource;
   end record;

   type Reader_Session is limited record
      Resource : Componolit.Gneiss.Platform.Resource_Descriptor :=
         Componolit.Gneiss.Platform.Invalid_Resource;
   end record;

end Componolit.Gneiss.Internal.Message;
