
with Gneiss_Internal;
with Gneiss;
with Gneiss.Component;

package Component with
   SPARK_Mode,
   Abstract_State => Platform_State,
   Initializes    => Platform_State
is

   procedure Construct (Cap : Gneiss.Capability) with
      Global => (In_Out => (Platform_State,
                            Main.Platform,
                            Gneiss_Internal.Platform_State));
   procedure Destruct with
      Global => (In_Out => (Platform_State,
                            Gneiss_Internal.Platform_State));

   package Main is new Gneiss.Component (Construct, Destruct);

end Component;
