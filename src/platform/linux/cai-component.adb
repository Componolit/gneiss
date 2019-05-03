
package body Cai.Component with
   SPARK_Mode => Off
is

   pragma Warnings (Off, "all instances of");

   procedure Platform_Construct (Cap : Cai.Types.Capability) with
      Export,
      Convention    => C,
      External_Name => "cai_component_construct";

   procedure Platform_Construct (Cap : Cai.Types.Capability)
   is
   begin
      Construct (Cap);
   end Platform_Construct;

   procedure Vacate (Cap    : Cai.Types.Capability;
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

   procedure Platform_Destruct with
      Export,
      Convention => C,
      External_Name => "cai_component_destruct";

   procedure Platform_Destruct
   is
   begin
      Destruct;
   end Platform_Destruct;

end Cai.Component;
