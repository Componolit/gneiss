
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
      procedure C_Vacate (S : Integer) with
         Import,
         Convention => C,
         External_Name => "vacate";
   begin
      if Status = Success then
         C_Vacate (0);
      else
         C_Vacate (1);
      end if;
   end Vacate;

end Componolit.Interfaces.Component;
