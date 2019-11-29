
with Gneiss.Types;
with Gneiss.Component;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Gneiss.Types.Capability);
   procedure Destruct;

   package Main is new Gneiss.Component (Construct, Destruct);

end Component;
