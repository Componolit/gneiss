
with Cai.Types;
with Cai.Component;

package Ada_Block_Test with
SPARK_Mode
is

   procedure Run;
   procedure Construct (Cap : Cai.Types.Capability);
   procedure Destruct;

   package Ada_Block_Test_Component is new Cai.Component (Construct, Destruct);

end Ada_Block_Test;
