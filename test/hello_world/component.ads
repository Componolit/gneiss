
with Gneiss;
with Gneiss.Component;
with Gneiss_Internal;

package Component with
   SPARK_Mode,
   Abstract_State => (Component_State, Platform_State),
   Initializes => (Platform_State)
is

   procedure Construct (Capability : Gneiss.Capability) with
      Global => (In_Out => (Platform_State,
                            Gneiss_Internal.Platform_State,
                            Main.Platform),
                 Output => Component_State);

   procedure Destruct with
      Global => (In_Out => (Platform_State, Gneiss_Internal.Platform_State));

   package Main is new Gneiss.Component (Construct, Destruct);

end Component;
