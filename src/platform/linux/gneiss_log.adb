
with Gneiss.Syscall;

package body Gneiss_Log with
   SPARK_Mode
is

   Blue       : constant String := Character'Val (8#33#) & "[34m";
   Red        : constant String := Character'Val (8#33#) & "[31m";
   Reset      : constant String := Character'Val (8#33#) & "[0m";
   Terminator : constant String := ASCII.LF & ASCII.NUL;

   procedure Info (S : String)
   is
   begin
      Gneiss.Syscall.Fputs ("I: " & S & Terminator);
   end Info;

   procedure Warning (S : String)
   is
   begin
      Gneiss.Syscall.Fputs (Blue & "W: " & S & Reset & Terminator);
   end Warning;

   procedure Error (S : String)
   is
   begin
      Gneiss.Syscall.Fputs (Red & "E: " & S & Reset & Terminator);
   end Error;

end Gneiss_Log;
