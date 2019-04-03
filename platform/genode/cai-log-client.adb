
with Cxx;
with Cxx.Genode;
with Cxx.Log.Client;
use all type Cxx.Bool;

package body Cai.Log.Client with
   SPARK_Mode => Off
is

   function Create return Client_Session
   is
   begin
      return Client_Session'(Instance => Cxx.Log.Client.Constructor);
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
   begin
      return Cxx.Log.Client.Initialized (C.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   procedure Initialize (C              : in out Client_Session;
                         Label          :        String;
                         Message_Length :        Integer := 0)
   is
      C_Label : String := Label & Character'Val (0);
   begin
      Cxx.Log.Client.Initialize (C.Instance, C_Label'Address, Cxx.Genode.Uint64_T (Message_Length));
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Cxx.Log.Client.Finalize (C.Instance);
   end Finalize;

   function Maximal_Message_Length (C : Client_Session) return Integer
   is
   begin
      return Integer (Cxx.Log.Client.Maximal_Message_Length (C.Instance));
   end Maximal_Message_Length;

   Blue       : constant String    := Character'Val (8#33#) & "[34m";
   Red        : constant String    := Character'Val (8#33#) & "[31m";
   Reset      : constant String    := Character'Val (8#33#) & "[0m";
   Terminator : constant Character := Character'Val (0);
   Nl         : constant Character := Character'Val (10);

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
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
                      Newline :        Boolean := True)
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
                    Newline :        Boolean := True)
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

end Cai.Log.Client;
