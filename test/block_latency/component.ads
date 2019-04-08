
with Cai.Component;

package Component with
   SPARK_Mode
is

   procedure Construct;

   package Latency_Test is new Cai.Component (Construct);

end Component;
