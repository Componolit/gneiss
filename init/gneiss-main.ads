
with Gneiss.Broker;

package Gneiss.Main with
   SPARK_Mode
is

   procedure Run (Name   :     String;
                  Fd     :     Integer;
                  Status : out Broker.Return_Code);

end Gneiss.Main;
