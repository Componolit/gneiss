
package Command_Line with
   SPARK_Mode
is

   function Argument_Count return Natural;

   function Argument (Number : Natural) return String with
      Pre => Number <= Argument_Count;

   procedure Set_Exit_Status (Status : Integer) with
      Pre           => Status < 256,
      Import,
      Convention    => C,
      External_Name => "__gnat_set_exit_status";

end Command_Line;
