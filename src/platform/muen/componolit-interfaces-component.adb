
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
      pragma Unreferenced (Cap);
      pragma Unreferenced (Status);
   begin
      null;
   end Vacate;

end Componolit.Interfaces.Component;
