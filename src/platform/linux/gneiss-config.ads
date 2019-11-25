
with System;

package Gneiss.Config with
   SPARK_Mode
is
   use type System.Address;

   type Config_Capability is private;

   procedure Load (Location   : String;
                   Capability : out Config_Capability);

   function Valid (Capability : Config_Capability) return Boolean;

   function Get_Address (Capability : Config_Capability) return System.Address with
      Pre  => Valid (Capability),
      Post => Get_Address'Result /= System.Null_Address;

   function Get_Length (Capability : Config_Capability) return Natural with
      Pre => Valid (Capability);

private

   type Config_Capability is record
      Address : System.Address;
   end record;

end Gneiss.Config;
