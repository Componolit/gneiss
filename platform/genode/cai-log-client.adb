with System;

package body Cai.Log.Client is

   procedure Info (Msg : String)
   is
      C_Str : String := Msg & Character'Val (0);
      procedure Log (C : System.Address) with
         Import,
         Convention => C,
         External_Name => "_ZN3Cai3logEPKc";
   begin
      Log (C_Str'Address);
   end Info;

   procedure Warning (Msg : String)
   is
      C_Str : String := Msg & Character'Val (0);
      procedure Log (C : System.Address) with
         Import,
         Convention => C,
         External_Name => "_ZN3Cai4warnEPKc";
   begin
      Log (C_Str'Address);
   end Warning;

   procedure Error (Msg : String)
   is
      C_Str : String := Msg & Character'Val (0);
      procedure Log (C : System.Address) with
         Import,
         Convention => C,
         External_Name => "_ZN3Cai3errEPKc";
   begin
      Log (C_Str'Address);
   end Error;

end Cai.Log.Client;
