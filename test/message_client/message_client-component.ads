
with Gneiss;
with Gneiss.Component;
with Gneiss_Internal;

package Message_Client.Component with
   SPARK_Mode,
   Abstract_State => (Component_State, Platform_State),
   Initializes    => (Platform_State, Main.Platform)
is

   procedure Construct (Cap : Gneiss.Capability) with
      Global => (Output => Component_State,
                 In_Out => (Platform_State,
                            Main.Platform,
                            Gneiss_Internal.Platform_State));

   procedure Destruct with
      Global => (In_Out => (Platform_State, Gneiss_Internal.Platform_State));

   package Main is new Gneiss.Component (Construct, Destruct);

end Message_Client.Component;
