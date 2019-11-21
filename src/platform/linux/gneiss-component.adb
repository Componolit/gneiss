
with Gneiss.Platform;

package body Gneiss.Component with
   SPARK_Mode => Off
is

   procedure Construct (Capability : Gneiss.Types.Capability)
   is
   begin
      Component_Construct (Capability);
   end Construct;

   procedure Destruct
   is
   begin
      Component_Destruct;
   end Destruct;

   procedure Vacate (Cap    : Gneiss.Types.Capability;
                     Status : Component_Status)
   is
   begin
      case Status is
         when Success =>
            Gneiss.Platform.Set_Status (Cap, 0);
         when Failure =>
            Gneiss.Platform.Set_Status (Cap, 1);
      end case;
   end Vacate;

end Gneiss.Component;
