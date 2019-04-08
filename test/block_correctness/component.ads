
with Cai.Component;

package Component with
   SPARK_Mode
is

   procedure Construct;

   package Correctness_Test is new Cai.Component (Construct);

   procedure Event;

end Component;
