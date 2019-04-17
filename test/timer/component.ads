
with Cai.Types;
with Cai.Component;

package Component with
   SPARK_Mode
is

   procedure Construct (Cap : Cai.Types.Capability);

   package Hello_World_Component is new Cai.Component (Construct);

end Component;
