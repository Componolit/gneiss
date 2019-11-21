
with Gneiss.Muen;

package body Gneiss.Component with
   SPARK_Mode => Off
is

   procedure Construct (Capability : Gneiss.Types.Capability)
   is
   begin
      Component_Construct (Capability);
   end Construct;

   procedure Destruct
   is
   begin
      Component_Destruct;
   end Destruct;

   procedure Vacate (Cap    : Gneiss.Types.Capability;
                     Status : Component_Status)
   is
      package CIM renames Gneiss.Muen;
      pragma Unreferenced (Cap);
   begin
      case Status is
         when Success =>
            CIM.Component_Status := CIM.Success;
         when Failure =>
            CIM.Component_Status := CIM.Failure;
      end case;
   end Vacate;

end Gneiss.Component;
