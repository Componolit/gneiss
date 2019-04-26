
package body Cai.Component is

   pragma Warnings (Off, "all instances of");

   procedure Shutdown (Cap    : Cai.Types.Capability;
                       Status : Shutdown_Status)
   is
      pragma Unreferenced (Cap);
      procedure C_Exit (S : Integer) with
         Import,
         Convention => C,
         External_Name => "exit";
   begin
      if Status = Success then
         C_Exit (0);
      else
         C_Exit (1);
      end if;
   end Shutdown;

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
