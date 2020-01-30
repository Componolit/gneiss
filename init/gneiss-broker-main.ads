
private with Gneiss_Epoll;

package Gneiss.Broker.Main with
   SPARK_Mode
is

   procedure Construct (Conf_Loc :     String;
                        Status   : out Integer);

private

   procedure Parse (Data : String);

   procedure Event_Loop (B_State : in out Broker_State;
                         Status  :    out Integer;
                         Efd     :        Gneiss_Epoll.Epoll_Fd);

end Gneiss.Broker.Main;
