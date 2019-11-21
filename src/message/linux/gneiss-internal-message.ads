
with Gneiss.Platform;

package Gneiss.Internal.Message with
   SPARK_Mode
is

   type Writer_Session is limited record
      Resource : Gneiss.Platform.Resource_Descriptor :=
         Gneiss.Platform.Invalid_Resource;
   end record;

   type Reader_Session is limited record
      Resource : Gneiss.Platform.Resource_Descriptor :=
         Gneiss.Platform.Invalid_Resource;
   end record;

end Gneiss.Internal.Message;
