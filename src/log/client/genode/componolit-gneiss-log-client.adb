
with Cxx;
with Cxx.Log.Client;
use all type Cxx.Bool;

package body Componolit.Gneiss.Log.Client
is

   procedure Initialize (C              : in out Client_Session;
                         Cap            :        Componolit.Gneiss.Types.Capability;
                         Label          :        String) with
      SPARK_Mode => Off
   is
      C_Label : String := Label & Character'Val (0);
   begin
      if not Initialized (C) then
         Cxx.Log.Client.Initialize (C.Instance,
                                    Cap,
                                    C_Label'Address);
      end if;
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      if Initialized (C) then
         Cxx.Log.Client.Finalize (C.Instance);
      end if;
   end Finalize;

   Blue       : constant String    := Character'Val (8#33#) & "[34m";
   Red        : constant String    := Character'Val (8#33#) & "[31m";
   Reset      : constant String    := Character'Val (8#33#) & "[0m";
   Terminator : constant Character := Character'Val (0);
   Nl         : constant Character := Character'Val (10);

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True) with
      SPARK_Mode => Off
   is
      C_Msg : String := Msg & (if Newline then Nl & Terminator else (1 => Terminator));
   begin
      Cxx.Log.Client.Write (C.Instance, C_Msg'Address);
      if Newline then
         Flush (C);
      end if;
   end Info;

   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True) with
      SPARK_Mode => Off
   is
      C_Msg : String := Blue & "Warning: " & Msg & Reset
                        & (if Newline then Nl & Terminator else (1 => Terminator));
   begin
      Cxx.Log.Client.Write (C.Instance, C_Msg'Address);
      if Newline then
         Flush (C);
      end if;
   end Warning;

   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True) with
      SPARK_Mode => Off
   is
      C_Msg : String := Red & "Error: " & Msg & Reset
                        & (if Newline then Nl & Terminator else (1 => Terminator));
   begin
      Cxx.Log.Client.Write (C.Instance, C_Msg'Address);
      if Newline then
         Flush (C);
      end if;
   end Error;

   procedure Flush (C : in out Client_Session)
   is
   begin
      Cxx.Log.Client.Flush (C.Instance);
   end Flush;

end Componolit.Gneiss.Log.Client;
