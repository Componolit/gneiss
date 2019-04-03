
package body Cai.Component is

   pragma Warnings (Off, "all instances of");
   --  This generic must only be instantiated once

   procedure Platform_Construct with
      Export,
      Convention    => C,
      External_Name => "cai_component_construct";

   procedure Platform_Construct
   is
   begin
      Construct;
   end Platform_Construct;

end Cai.Component;
