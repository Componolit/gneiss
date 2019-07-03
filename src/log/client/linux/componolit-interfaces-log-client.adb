
with System;
use all type System.Address;

package body Componolit.Interfaces.Log.Client
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
      (C.Label /= System.Null_Address);

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (C              : in out Client_Session;
                         Cap            :        Componolit.Interfaces.Types.Capability;
                         Label          :        String) with
      SPARK_Mode => Off
   is
      pragma Unreferenced (Cap);
      procedure C_Initialize (Str :     System.Address;
                              Lbl : out System.Address) with
         Import,
         Convention    => C,
         External_Name => "initialize",
         Global        => null;

      C_Str : String := Label & Character'Val (0);
   begin
      C_Initialize (C_Str'Address, C.Label);
      C.Length := Label'Length;
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (C : in out Client_Session)
   is
      procedure C_Finalize (Label : System.Address) with
         Import,
         Convention    => C,
         External_Name => "finalize",
         Global        => null;
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
      (4095);

   procedure Print (Msg : System.Address) with
      Import,
      Convention    => C,
      External_Name => "print",
      Global        => null;

   procedure Print_With_Null_Term (S : String);

   procedure Print_With_Null_Term (S : String) with
      SPARK_Mode => Off
   is
      C_Str : String := S & Character'First;
   begin
      Print (C_Str'Address);
   end Print_With_Null_Term;

   procedure Print_String (Label   : System.Address;
                           Use_L   : Boolean;
                           Prefix  : String;
                           Message : String;
                           Newline : Boolean) with
      Pre => Label /= System.Null_Address;

   procedure Print_String (Label   : System.Address;
                           Use_L   : Boolean;
                           Prefix  : String;
                           Message : String;
                           Newline : Boolean)
   is
   begin
      if Use_L then
         Print_With_Null_Term ("[");
         Print (Label);
         Print_With_Null_Term ("] ");
         Print_With_Null_Term (Prefix);
      end if;
      Print_With_Null_Term (Message);
      if Newline then
         Print_With_Null_Term ((1 => Character'Val (10)));
      end if;
   end Print_String;

   ----------
   -- Info --
   ----------

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
   begin
      C.Prev_Nl := Newline;
      Print_String (C.Label, C.Prev_Nl, "Info: ", Msg, Newline);
   end Info;

   -------------
   -- Warning --
   -------------

   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
   begin
      C.Prev_Nl := Newline;
      Print_String (C.Label, C.Prev_Nl, "Warning: ", Msg, Newline);
   end Warning;

   -----------
   -- Error --
   -----------

   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
   begin
      C.Prev_Nl := Newline;
      Print_String (C.Label, C.Prev_Nl, "Warning: ", Msg, Newline);
   end Error;

   -----------
   -- Flush --
   -----------

   procedure Flush (C : in out Client_Session) with
      SPARK_Mode => Off
   is
      M : String := Character'Val (10) & Character'Val (0);
   begin
      if not C.Prev_Nl then
         Print (M'Address);
      end if;
   end Flush;

end Componolit.Interfaces.Log.Client;
