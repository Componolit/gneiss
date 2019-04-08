
package body Cai.Component is

   pragma Warnings (Off, "all instances of");

   procedure Platform_Construct with
      Export,
      Convention    => C,
      External_Name => "cai_component_construct";

   procedure Platform_Construct
   is
      Cap : Cai.Types.Capability;
   begin
      Construct (Cap);
   end Platform_Construct;

end Cai.Component;
