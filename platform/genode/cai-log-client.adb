with System;

package body Cai.Log.Client is

   procedure Stdout (Msg : String)
   is
      C_Str : String := Msg & Character'Val (0);
      procedure Log (C : System.Address) with
         Import,
         Convention => C,
         External_Name => "_ZN3Cai3logEPKc";
   begin
      Log (C_Str'Address);
   end Stdout;

   procedure Stderr (Msg : String)
   is
      C_Str : String := Msg & Character'Val (0);
      procedure Log (C : System.Address) with
         Import,
         Convention => C,
         External_Name => "_ZN3Cai3errEPKc";
   begin
      Log (C_Str'Address);
   end Stderr;

end Cai.Log.Client;
