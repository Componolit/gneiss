with System.Storage_Elements;
with Sparkfun.Debug;
package body Serial is

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

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      ENABLE   := (ENABLE => Disabled);
      GPIO.Configure (27, GPIO.Port_Out);
      PSEL_TXD := (CONNECT => Connected, PIN => 27);
      CONFIG   := (HWFC => False, PARITY => Excluded);
      BAUDRATE := (BAUDRATE => Baud115200);
      ENABLE   := (ENABLE => Enabled);
   end Initialize;

   -----------
   -- Print --
   -----------

   procedure Print (Str : String) is
   begin
      TXD_PTR       := (PTR => Str'Address);
      TXD_MAXCNT    := (MAXCNT => Str'Length);
      TASKS_STARTTX := (TSK => Trigger);

      while EVENT_ENDTX.EVENT = Clear  loop
         Debug (TXD_AMOUNT.AMOUNT);
      end loop;
      EVENT_ENDTX.EVENT := Clear;
   end Print;

end Serial;