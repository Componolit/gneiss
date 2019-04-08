
with Cai.Types;
with Cai.Component;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Cai.Types.Capability);

   package Correctness_Test is new Cai.Component (Construct);

   procedure Event;

end Component;
