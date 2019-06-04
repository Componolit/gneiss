
with Componolit.Interfaces.Types;
with Componolit.Interfaces.Component;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability);
   procedure Destruct;

   package Main is new Componolit.Interfaces.Component (Construct, Destruct);

end Component;
