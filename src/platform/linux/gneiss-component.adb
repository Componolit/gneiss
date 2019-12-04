
with Gneiss_Platform;

package body Gneiss.Component with
   SPARK_Mode => Off
is

   procedure Construct (Cap : Capability)
   is
   begin
      Component_Construct (Cap);
   end Construct;

   procedure Destruct
   is
   begin
      Component_Destruct;
   end Destruct;

   procedure Vacate (Cap    : Capability;
                     Status : Component_Status)
   is
   begin
      case Status is
         when Success =>
            Gneiss_Platform.Call (Cap.Set_Status, 0);
         when Failure =>
            Gneiss_Platform.Call (Cap.Set_Status, 1);
      end case;
   end Vacate;

end Gneiss.Component;
