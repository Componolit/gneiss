package body Gneiss.Init with
   SPARK_Mode
is

   function Create_Capability (Reg : System.Address;
                               Idx : Natural) return Capability
   is
   begin
      return (Reg, Idx);
   end Create_Capability;

end Gneiss.Init;
