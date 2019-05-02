
with Cai.Types;
with Cai.Component;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Cai.Types.Capability);
   procedure Destruct;

   package Hello_World_Component is new Cai.Component (Construct, Destruct);

end Component;
