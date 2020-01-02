
with Gneiss.Libc;

package body Gneiss.Config with
   SPARK_Mode
is

   procedure Load (Location : String;
                   Cap      : out Config_Capability)
   is
      procedure Load (Loc :     System.Address;
                      C   : out System.Address) with
         Import,
         Convention    => C,
         External_Name => "gneiss_load_config";
      C_Loc : String := Location & ASCII.NUL;
   begin
      Cap := Config_Capability'(Address => System.Null_Address);
      Load (C_Loc'Address, Cap.Address);
   end Load;

   function Valid (Cap : Config_Capability) return Boolean is
      (Cap.Address /= System.Null_Address);

   function Get_Address (Cap : Config_Capability) return System.Address is
      (Cap.Address);

   function Get_Length (Cap : Config_Capability) return Natural is
      (if Libc.Strlen (Cap.Address) >= 0 then Libc.Strlen (Cap.Address) else 0);

end Gneiss.Config;
