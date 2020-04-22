
with Gneiss.Broker;
with Gneiss_Internal;

package Gneiss.Main with
   SPARK_Mode
is

   procedure Run (Name   :     String;
                  Fd     :     Gneiss_Internal.File_Descriptor;
                  Status : out Broker.Return_Code);

end Gneiss.Main;
