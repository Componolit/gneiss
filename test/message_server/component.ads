
with Gneiss;
with Gneiss.Component;

package Component with
   SPARK_Mode
is

   package Gns renames Gneiss;

   procedure Construct (Cap : Gns.Capability);
   procedure Destruct;

   package Main is new Gns.Component (Construct, Destruct);

end Component;
