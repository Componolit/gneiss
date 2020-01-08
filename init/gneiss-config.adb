
with System;

package body Gneiss.Config with
   SPARK_Mode => Off
is

   procedure C_Load (File : System.Address;
                     Func : System.Address) with
      Import,
      Convention => C,
      External_Name => "gneiss_load_config";

   procedure Raw_Parse (Char : System.Address;
                        Size : Integer);

   procedure Load (Location : String)
   is
      C_Loc : String := Location & ASCII.NUL;
   begin
      C_Load (C_Loc'Address, Raw_Parse'Address);
   end Load;

   procedure Raw_Parse (Char : System.Address;
                        Size : Integer)
   is
      Data : String (1 .. Size) with
         Import,
         Address => Char;
   begin
      Parse (Data);
   end Raw_Parse;

end Gneiss.Config;
