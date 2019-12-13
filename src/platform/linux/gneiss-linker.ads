
with System;

package Gneiss.Linker with
   SPARK_Mode,
   Abstract_State => Linux,
   Initializes    => Linux
is

   type Dl_Handle is private;
   Invalid_Handle : constant Dl_Handle;

   procedure Open (File   :     String;
                   Handle : out Dl_Handle) with
      Global => (In_Out => Linux);

   function Symbol (Handle : Dl_Handle;
                    Name   : String) return System.Address with
      Global => (Input => Linux),
      Pre    => Handle /= Invalid_Handle;

private

   type Dl_Handle is new System.Address;

   Invalid_Handle : constant Dl_Handle := Dl_Handle (System.Null_Address);

end Gneiss.Linker;
