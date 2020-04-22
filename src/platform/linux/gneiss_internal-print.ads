
package Gneiss_Internal.Print with
   SPARK_Mode
is

   procedure Info (S : String) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Warning (S : String) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Error (S : String) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

end Gneiss_Internal.Print;
