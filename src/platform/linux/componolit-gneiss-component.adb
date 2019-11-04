
with Componolit.Gneiss.Platform;

package body Componolit.Gneiss.Component with
   SPARK_Mode => Off
is

   procedure Construct (Capability : Componolit.Gneiss.Types.Capability)
   is
   begin
      Component_Construct (Capability);
   end Construct;

   procedure Destruct
   is
   begin
      Component_Destruct;
   end Destruct;

   procedure Vacate (Cap    : Componolit.Gneiss.Types.Capability;
                     Status : Component_Status)
   is
   begin
      case Status is
         when Success =>
            Componolit.Gneiss.Platform.Set_Status (Cap, 0);
         when Failure =>
            Componolit.Gneiss.Platform.Set_Status (Cap, 1);
      end case;
   end Vacate;

end Componolit.Gneiss.Component;
