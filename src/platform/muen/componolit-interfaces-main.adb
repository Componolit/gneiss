with Ada.Unchecked_Conversion;
with Component;
with SK.CPU;
with Componolit.Interfaces.Types;
with Componolit.Interfaces.Internal.Types;
with Componolit.Interfaces.Muen;

package body Componolit.Interfaces.Main with
   SPARK_Mode
is

   procedure Run with
      SPARK_Mode
   is
      package CIM renames Componolit.Interfaces.Muen;
      use type CIM.Status;
      Null_Cap : constant Componolit.Interfaces.Internal.Types.Capability := (null record);
      function Gen_Cap is new Ada.Unchecked_Conversion (Componolit.Interfaces.Internal.Types.Capability,
                                                        Componolit.Interfaces.Types.Capability);
   begin
      Component.Main.Construct (Gen_Cap (Null_Cap));
      while CIM.Component_Status = CIM.Running loop
         null;
      end loop;
      SK.CPU.Stop;
   end Run;

end Componolit.Interfaces.Main;
