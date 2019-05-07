
with Cai.Types;
with Cai.Component;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Cai.Types.Capability);
   procedure Destruct;

   package Timer_Component is new Cai.Component (Construct, Destruct);

end Component;
