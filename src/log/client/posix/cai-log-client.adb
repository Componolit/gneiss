
with System;
use all type System.Address;

package body Cai.Log.Client with
   SPARK_Mode => Off
is

   ------------
   -- Create --
   ------------

   function Create return Client_Session is
   begin
      return Client_Session'(Label          => System.Null_Address,
                             Length         => 0,
                             Prev_Nl        => True);
   end Create;

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

   procedure Initialize (C              : in out Client_Session;
                         Cap            :        Cai.Types.Capability;
                         Label          :        String)
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
   -- Maximum_Message_Length --
   ----------------------------

   function Maximum_Message_Length (C : Client_Session) return Integer
   is
      pragma Unreferenced (C);
   begin
      return 4095;
   end Maximum_Message_Length;

   procedure Print (Msg : System.Address) with
      Import,
      Convention    => C,
      External_Name => "print";

   function Create_String (Label   : String;
                           Use_L   : Boolean;
                           Prefix  : String;
                           Message : String;
                           Newline : Boolean) return String is
      ((if Use_L then "[" & Label & "] " & Prefix else "") & Message
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
      M : String := Create_String (Label, C.Prev_Nl, "Info: ", Msg, Newline);
   begin
      C.Prev_Nl := Newline;
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
      M : String := Create_String (Label, C.Prev_Nl, "Warning: ", Msg, Newline);
   begin
      C.Prev_Nl := Newline;
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
      M : String := Create_String (Label, C.Prev_Nl, "Error: ", Msg, Newline);
   begin
      C.Prev_Nl := Newline;
      Print (M'Address);
   end Error;

   -----------
   -- Flush --
   -----------

   procedure Flush (C : in out Client_Session)
   is
      M : String := Character'Val (10) & Character'Val (0);
   begin
      if not C.Prev_Nl then
         Print (M'Address);
      end if;
   end Flush;

end Cai.Log.Client;
