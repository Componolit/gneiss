
with Ada.Unchecked_Conversion;
with Gneiss.Internal.Types;

package body Gneiss.Platform with
   SPARK_Mode
is

   function Convert is new Ada.Unchecked_Conversion
      (Gneiss.Types.Capability, Gneiss.Internal.Types.Capability);

   procedure Set_Status (C : Gneiss.Types.Capability;
                         S : Integer)
   is
      procedure Set (St : Integer) with
         Import,
         Address => Convert (C).Set_Status;
   begin
      Set (S);
   end Set_Status;

end Gneiss.Platform;
