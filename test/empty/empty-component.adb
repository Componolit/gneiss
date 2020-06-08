
package body Empty.Component with
   SPARK_Mode
is

   I : Integer;

   procedure Construct (Capability : Gneiss.Capability)
   is
   begin
      null;
   end Construct;

   procedure Destruct
   is
   begin
      null;
   end Destruct;

begin
   I := 42;
end Empty.Component;
