
with System;

package Gneiss_Internal.Linker with
   SPARK_Mode
is

   type Dl_Handle is private;
   Invalid_Handle : constant Dl_Handle;

   procedure Open (File   :     String;
                   Handle : out Dl_Handle) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   function Symbol (Handle : Dl_Handle;
                    Name   : String) return System.Address with
      Global => (Input => Gneiss_Internal.Platform_State),
      Pre    => Handle /= Invalid_Handle;

private

   type Dl_Handle is new System.Address;

   Invalid_Handle : constant Dl_Handle := Dl_Handle (System.Null_Address);

end Gneiss_Internal.Linker;
