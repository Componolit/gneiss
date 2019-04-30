
package body Cai.Component with
   SPARK_Mode => Off
is

   pragma Warnings (Off, "all instances of");
   --  This generic must only be instantiated once

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
      procedure C_Vacate (C : Cai.Types.Capability;
                          S : Integer) with
         Import,
         Convention => C,
         External_Name => "cai_component_vacate";
   begin
      if Status = Success then
         C_Vacate (Cap, 0);
      else
         C_Vacate (Cap, 1);
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
