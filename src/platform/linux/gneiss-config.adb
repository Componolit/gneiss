
with Gneiss.Libc;

package body Gneiss.Config with
   SPARK_Mode
is

   procedure Load (Location   : String;
                   Capability : out Config_Capability)
   is
      procedure Load (Loc : System.Address;
                      Cap : out System.Address) with
         Import,
         Convention    => C,
         External_Name => "gneiss_load_config";
      C_Loc : String := Location & ASCII.NUL;
   begin
      Capability := Config_Capability'(Address => System.Null_Address);
      Load (C_Loc'Address, Capability.Address);
   end Load;

   function Valid (Capability : Config_Capability) return Boolean is
      (Capability.Address /= System.Null_Address);

   function Get_Address (Capability : Config_Capability) return System.Address is
      (Capability.Address);

   function Get_Length (Capability : Config_Capability) return Natural is
      (if Libc.Strlen (Capability.Address) >= 0 then Libc.Strlen (Capability.Address) else 0);

end Gneiss.Config;
