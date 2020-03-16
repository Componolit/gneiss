
package Gneiss.Broker.Main with
   SPARK_Mode
is

   procedure Construct (Conf_Loc :     String;
                        Status   : out Integer);

private

   procedure Parse (Data : String);

   procedure Event_Loop (B_State : in out Broker_State;
                         Status  :    out Integer);

end Gneiss.Broker.Main;
