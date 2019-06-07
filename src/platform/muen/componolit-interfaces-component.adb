
with Componolit.Interfaces.Muen;

package body Componolit.Interfaces.Component with
   SPARK_Mode => Off
is

   procedure Construct (Capability : Componolit.Interfaces.Types.Capability)
   is
   begin
      Component_Construct (Capability);
   end Construct;

   procedure Destruct
   is
   begin
      Component_Destruct;
   end Destruct;

   procedure Vacate (Cap    : Componolit.Interfaces.Types.Capability;
                     Status : Component_Status)
   is
      package CIM renames Componolit.Interfaces.Muen;
      pragma Unreferenced (Cap);
   begin
      case Status is
         when Success =>
            CIM.Component_Status := CIM.Success;
         when Failure =>
            CIM.Component_Status := CIM.Failure;
      end case;
   end Vacate;

end Componolit.Interfaces.Component;
