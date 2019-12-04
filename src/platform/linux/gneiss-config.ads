
with System;

package Gneiss.Config with
   SPARK_Mode
is
   use type System.Address;

   type Config_Capability is private;

   procedure Load (Location : String;
                   Cap      : out Config_Capability);

   function Valid (Cap : Config_Capability) return Boolean;

   function Get_Address (Cap : Config_Capability) return System.Address with
      Pre  => Valid (Cap),
      Post => Get_Address'Result /= System.Null_Address;

   function Get_Length (Cap : Config_Capability) return Natural with
      Pre => Valid (Cap);

private

   type Config_Capability is record
      Address : System.Address;
   end record;

end Gneiss.Config;
