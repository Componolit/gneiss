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
      null;
   end Vacate;

end Gneiss.Component;
