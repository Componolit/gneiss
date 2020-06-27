with Gneiss;
with Gneiss.Component;
with Gneiss_Internal;

package Stream_Server.Component with
   SPARK_Mode,
   Abstract_State => (Platform_State, Component_State),
   Initializes    => (Platform_State, Main.Platform)
is

   procedure Construct (Cap : Gneiss.Capability) with
      Global => (In_Out => (Platform_State,
                            Gneiss_Internal.Platform_State,
                            Main.Platform),
                 Output => Component_State);

   procedure Destruct with
      Global => null;

   package Main is new Gneiss.Component (Construct, Destruct);

end Stream_Server.Component;
