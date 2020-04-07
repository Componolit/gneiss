
with Gneiss_Epoll;

package Gneiss.Broker.Main with
   SPARK_Mode
is

   procedure Construct (Conf_Loc :     String;
                        Status   : out Return_Code);

private

   procedure Parse (Data : String);

   procedure Event_Loop (B_State : in out Broker_State;
                         Status  :    out Return_Code) with
      Pre => Gneiss_Epoll.Valid_Fd (B_State.Epoll_Fd)
             and then Is_Valid (B_State.Xml, B_State.Components)
             and then Is_Valid (B_State.Xml, B_State.Resources);

end Gneiss.Broker.Main;
