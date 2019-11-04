
with Ada.Unchecked_Conversion;
with Componolit.Gneiss.Internal.Types;
with Componolit.Runtime.Debug;
with System;

package body Componolit.Gneiss.Platform with
   SPARK_Mode => Off
is

   function Convert is new Ada.Unchecked_Conversion (Gns.Types.Capability, Gns.Internal.Types.Capability);

   procedure Set_Status (C : Gns.Types.Capability;
                         S : Integer)
   is
      use type System.Address;
      procedure Set (Cp : Gns.Types.Capability;
                     St : Integer) with
         Import,
         Address => Convert (C).Set_Status;
   begin
      if Convert (C).Set_Status = System.Null_Address then
         Componolit.Runtime.Debug.Log_Error ("Null Pointer!");
      end if;
      Set (C, S);
   end Set_Status;

end Componolit.Gneiss.Platform;
