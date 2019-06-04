with Ada.Unchecked_Conversion;
with Component;
with Componolit.Interfaces.Types;
with SK.CPU;

package body Componolit.Interfaces.Muen with
   SPARK_Mode
is

   procedure Main with
      SPARK_Mode
   is
      function Gen_Cap is new Ada.Unchecked_Conversion
         (Integer,
          Componolit.Interfaces.Types.Capability);
      Cap : constant Componolit.Interfaces.Types.Capability := Gen_Cap (0);
   begin
      Component.Main.Construct (Cap);
      SK.CPU.Stop;
   end Main;

end Componolit.Interfaces.Muen;
