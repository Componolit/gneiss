
with SXML.Parser;
with Gneiss_Epoll;
with Gneiss.Linker;
with Gneiss.Syscall;
with Gneiss.Main;

package Gneiss.Broker with
   SPARK_Mode,
   Abstract_State => Policy_State,
   Initializes    => Policy_State
is

   function Is_Valid return Boolean with
      Ghost;

   procedure Construct (Config :     String;
                        Status : out Integer) with
      Post   => Is_Valid,
      Global => (In_Out => (Policy_State,
                            Gneiss.Main.Component_State,
                            Gneiss.Linker.Linux,
                            Gneiss.Syscall.Linux,
                            Gneiss_Epoll.Linux,
                            SXML.Parser.State));

   function Initialized return Boolean with
      Pre    => Is_Valid,
      Post   => (if Initialized'Result then Is_Valid),
      Global => (Input => Policy_State);

end Gneiss.Broker;
