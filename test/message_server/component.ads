
with Componolit.Gneiss.Types;
with Componolit.Gneiss.Component;

package Component with
   SPARK_Mode
is

   package Gns renames Componolit.Gneiss;

   procedure Construct (Cap : Gns.Types.Capability);
   procedure Destruct;

   package Main is new Gns.Component (Construct, Destruct);

end Component;
