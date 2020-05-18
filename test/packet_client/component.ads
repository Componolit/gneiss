
with Gneiss;
with Gneiss.Component;
with Gneiss_Internal;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Gneiss.Capability);

   procedure Destruct;

   package Main is new Gneiss.Component (Construct, Destruct);

end Component;
