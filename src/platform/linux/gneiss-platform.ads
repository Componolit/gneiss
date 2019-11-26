
with Gneiss.Types;

package Gneiss.Platform with
   SPARK_Mode
is
   --  Set the application return state
   --
   --  @param C  System capability
   --  @param S  Status code (0 - Success, 1 - Failure)
   procedure Set_Status (C : Gneiss.Types.Capability;
                         S : Integer);

end Gneiss.Platform;
