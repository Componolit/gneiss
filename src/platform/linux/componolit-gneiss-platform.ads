
with Componolit.Gneiss.Types;

package Componolit.Gneiss.Platform with
   SPARK_Mode => Off
is
   package Gns renames Componolit.Gneiss;

   procedure Set_Status (C : Gns.Types.Capability;
                         S : Integer);

end Componolit.Gneiss.Platform;
