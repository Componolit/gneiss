
with Gneiss;
with Gneiss.Component;

package Component with
   SPARK_Mode
is

   procedure Construct (Capability : Gneiss.Capability);
   procedure Destruct;

   package Main is new Gneiss.Component (Construct, Destruct);

end Component;
