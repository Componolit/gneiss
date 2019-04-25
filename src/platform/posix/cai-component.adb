
package body Cai.Component is

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

end Cai.Component;
