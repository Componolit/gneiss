with Componolit.Runtime.Debug;

package body Empty.Component with
   SPARK_Mode
is

   procedure Construct (Capability : Gneiss.Capability)
   is
      pragma Unreferenced (Capability);
   begin
      Componolit.Runtime.Debug.Log_Debug ("Empty Construct");
   end Construct;

   procedure Destruct
   is
   begin
      null;
   end Destruct;

end Empty.Component;
