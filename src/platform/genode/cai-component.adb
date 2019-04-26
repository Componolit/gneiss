
package body Cai.Component is

   pragma Warnings (Off, "all instances of");
   --  This generic must only be instantiated once

   procedure Shutdown (Cap    : Cai.Types.Capability;
                       Status : Shutdown_Status)
   is
      procedure Genode_Exit (C : Cai.Types.Capability;
                             S : Integer) with
         Import,
         Convention => CPP,
         External_Name => "cai_component_exit";
   begin
      if Status = Success then
         Genode_Exit (Cap, 0);
      else
         Genode_Exit (Cap, 1);
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
