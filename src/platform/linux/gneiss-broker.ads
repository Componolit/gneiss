
package Gneiss.Broker with
   SPARK_Mode,
   Abstract_State => (Policy_State,
                      Loader_State,
                      Message_State),
   Initializes    => (Policy_State,
                      Loader_State,
                      Message_State)
is

   function Is_Valid return Boolean with
      Ghost;

   procedure Construct (Config :     String;
                        Status : out Integer) with
      Post   => Is_Valid,
      Global => (In_Out => Policy_State);

   function Initialized return Boolean with
      Pre    => Is_Valid,
      Post   => (if Initialized'Result then Is_Valid),
      Global => (Input => Policy_State);

end Gneiss.Broker;
