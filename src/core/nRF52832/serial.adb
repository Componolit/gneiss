with System.Storage_Elements;
with Sparkfun.Debug;
package body Serial with
SPARK_Mode
is

   procedure Debug is new Sparkfun.Debug.Debug (Count);
   package SSE renames System.Storage_Elements;
   use type SSE.Integer_Address;

   Base : constant SSE.Integer_Address := 16#40002000#;

   TASKS_STARTTX : Reg_TASK with
     Import,
     Address => SSE.To_Address (Base + 16#8#);

   TASKS_STOPTX : Reg_TASK with
     Import,
     Address => SSE.To_Address (Base + 16#C#);

   EVENT_ENDTX : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#120#);

   EVENT_TXSTOPPED : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#158#);

   ENABLE : Reg_ENABLE with
     Import,
     Address => SSE.To_Address (Base + 16#500#);

   PSEL_TXD : Reg_PSEL_TXD with
     Import,
     Address => SSE.To_Address (Base + 16#50C#);

   PSELTXD : Reg_PSELTXD with
     Import,
     Address => SSE.To_Address (Base + 16#50C#);

   TXD_MAXCNT : Reg_TXD_MAXCNT with
     Import,
     Address => SSE.To_Address (Base + 16#548#);

   TXD_AMOUNT : Reg_TXD_AMOUNT with
     Import,
     Address => SSE.To_Address (Base + 16#54C#);

   CONFIG : Reg_CONFIG with
     Import,
     Address => SSE.To_Address (Base + 16#56C#);

   BAUDRATE : Reg_BAUDRATE with
     Import,
     Address => SSE.To_Address (Base + 16#524#);

   TXD_PTR : Reg_TXD_PTR with
     Import,
     Address => SSE.To_Address (Base + 16#544#);

   EVENT_TXSTARTED : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#150#);

   TXD : Reg_TXD with
     Import,
     Address => SSE.To_Address (Base + 16#51C#);

   EVENT_TXDRDY : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#11C#);

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      ENABLE   := (ENABLE => Disabled);
      GPIO.Configure (6, GPIO.Port_Out);
      GPIO.Write (6, GPIO.High);
      PSEL_TXD := (CONNECT => Connected, PIN => 6);
      CONFIG   := (HWFC => False, PARITY => Excluded);
      BAUDRATE := (BAUDRATE => Baud115200);
      ENABLE   := (ENABLE => Enabled_UARTE);
   end Initialize;

   -----------
   -- Print --
   -----------
   Buffer : String (1 .. 32) := (others => Character'First);

   procedure Print (Str : String) is
      StrI : Positive := Str'First;
   begin
      Sparkfun.Debug.Debug_Address (String_Address (Buffer));
      if Str'Length > Buffer'Length then
         TXD_MAXCNT := (MAXCNT => Buffer'Length);
         Debug (1);
         Buffer := Str (Str'First .. Str'First + Buffer'Length - 1);
         Debug (2);
      else
         Debug (3);
         TXD_MAXCNT := (MAXCNT => Str'Length);
         Debug (8);
         for B in Buffer'First .. Buffer'First + Str'Length - 1 loop
            Buffer (B) := Str (StrI);
            StrI := StrI + 1;
         end loop;

         Debug (4);
      end if;
      TXD_PTR       := (PTR => String_Address (Buffer));
      Debug (5);
      --   TXD_PTR := (PTR => String_Address (Str));
      --   TXD_MAXCNT := (MAXCNT => Str'Length);
      TASKS_STARTTX := (TSK => Trigger);
      Debug (6);
      while EVENT_ENDTX.EVENT = Clear  loop
         Debug (TXD_AMOUNT.AMOUNT);
      end loop;
      Debug (7);
      EVENT_ENDTX.EVENT := Clear;
   end Print;

   --------------------
   -- String_Address --
   --------------------

   function String_Address (S : String) return System.Address with
     SPARK_Mode => Off
   is
   begin
      return S'Address;
   end String_Address;

end Serial;
