
with Componolit.Gneiss.Types;
with Componolit.Gneiss.Component;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability);
   procedure Destruct;

   package Main is new Componolit.Gneiss.Component (Construct, Destruct);

end Component;
