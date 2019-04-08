
with System;
use all type System.Address;

package body Cai.Log.Client with
   SPARK_Mode => Off
is

   -----------------
   -- Initialized --
   -----------------

   function Initialized (C : Client_Session) return Boolean is
   begin
      return C.Label /= System.Null_Address;
   end Initialized;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (C              : out Client_Session;
                         Cap            :     Cai.Types.Capability;
                         Label          :     String;
                         Message_Length :     Integer := 0)
   is
      pragma Unreferenced (Cap);
      procedure C_Initialize (Str :     System.Address;
                              Lbl : out System.Address) with
         Import,
         Convention    => C,
         External_Name => "initialize";

      C_Str : String := Label & Character'Val (0);
   begin
      C_Initialize (C_Str'Address, C.Label);
      C.Length         := Label'Length;
      C.Message_Length := (if Message_Length > 0 then Message_Length else 4095);
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (C : in out Client_Session)
   is
      procedure C_Finalize (Label : System.Address) with
         Import,
         Convention    => C,
         External_Name => "finalize";
   begin
      C_Finalize (C.Label);
      C.Label  := System.Null_Address;
      C.Length := 0;
   end Finalize;

   ----------------------------
   -- Maximal_Message_Length --
   ----------------------------

   function Maximal_Message_Length (C : Client_Session) return Integer
   is
   begin
      return C.Message_Length;
   end Maximal_Message_Length;

   procedure Print (Msg : System.Address) with
      Import,
      Convention    => C,
      External_Name => "print";

   function Create_String (Label   : String;
                           Prefix  : String;
                           Message : String;
                           Newline : Boolean) return String is
      ("[" & Label & "] " & Prefix & Message
       & (if Newline
          then Character'Val (10) & Character'Val (0)
          else (1 => Character'Val (0))));

   ----------
   -- Info --
   ----------

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
      Label : String (1 .. C.Length) with
         Address => C.Label;
      M : String := Create_String (Label, "Info: ", Msg, Newline);
   begin
      Print (M'Address);
   end Info;

   -------------
   -- Warning --
   -------------

   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
      Label : String (1 .. C.Length) with
         Address => C.Label;
      M : String := Create_String (Label, "Warning: ", Msg, Newline);
   begin
      Print (M'Address);
   end Warning;

   -----------
   -- Error --
   -----------

   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
      Label : String (1 .. C.Length) with
         Address => C.Label;
      M : String := Create_String (Label, "Error: ", Msg, Newline);
   begin
      Print (M'Address);
   end Error;

   -----------
   -- Flush --
   -----------

   procedure Flush (C : in out Client_Session)
   is
      pragma Unreferenced (C);
   begin
      null;
   end Flush;

end Cai.Log.Client;
