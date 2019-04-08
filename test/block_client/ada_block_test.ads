
with Cai.Component;

package Ada_Block_Test with
SPARK_Mode
is

   procedure Run;
   procedure Construct;

   package Ada_Block_Test_Component is new Cai.Component (Construct);

end Ada_Block_Test;
