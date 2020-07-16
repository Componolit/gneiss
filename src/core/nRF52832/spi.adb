with System.Storage_Elements;

package body Spi with
SPARK_Mode
is
   package SSE renames System.Storage_Elements;
   use type SSE.Integer_Address;

   Base : constant SSE.Integer_Address := 16#40003000#;

   ENABLE : Reg_Enable with
     Import,
     Address => SSE.To_Address (Base + 16#500#);

   CONFIG_CPOL : Reg_SPIM_CONFIG_CPOL with
     Import,
     Address => SSE.To_Address (Base + 16#554#);

   PSEL_SCK : Reg_PSEL_SCK with
     Import,
     Address => SSE.To_Address (Base + 16#508#);

   PSEL_MOSI : Reg_PSEL_MOSI with
     Import,
     Address => SSE.To_Address (Base + 16#50C#);

   TASK_START : Reg_TASK with
     Import,
     Address => SSE.To_Address (Base + 16#010#);

   TASK_STOP : Reg_TASK with
     Import,
     Address => SSE.To_Address (Base + 16#014#);

   TASK_SUSPEND : Reg_TASK with
     Import,
     Address => SSE.To_Address (Base + 16#01C#);

   TASK_RESUME : Reg_TASK with
     Import,
     Address => SSE.To_Address (Base + 16#020#);

   EVENT_STOPPED : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#104#);

   EVENT_ENDRX : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#110#);

   EVENT_END : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#118#);

   EVENT_ENDTX : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#120#);

   EVENT_STARTED : Reg_EVENT with
     Import,
     Address => SSE.To_Address (Base + 16#14C#);

   FREQUENCY : Reg_SPIM_Frequency with
     Import,
     Address => SSE.To_Address (Base + 16#524#);

   TXD_PTR : Reg_TXD_PTR with
     Import,
     Address => SSE.To_Address (Base + 16#544#);

   TXD_MAXCNT : Reg_TXD_MAXCNT with
     Import,
     Address => SSE.To_Address (Base + 16#548#);

   TXD_AMOUNT : Reg_TXD_AMOUNT with
     Import,
     Address => SSE.To_Address (Base + 16#54C#);

   RXD_PTR : Reg_RXD_PTR with
     Import,
     Address => SSE.To_Address (Base + 16#534#);

   RXD_MAXCNT : Reg_RXD_MAXCNT with
     Import,
     Address => SSE.To_Address (Base + 16#538#);

   RXD_AMOUNT : Reg_RXD_AMOUNT with
     Import,
     Address => SSE.To_Address (Base + 16#53C#);

   procedure Initialize is
   begin
      ENABLE := (ENABLE => Disabled);
      GPIO.Configure (26, GPIO.Port_Out);
      GPIO.Write (26, GPIO.High);
      GPIO.Configure (27, GPIO.Port_Out);
      GPIO.Write (27, GPIO.High);
      PSEL_SCK  := (CONNECT => Connected, PIN => 26);
      PSEL_MOSI := (CONNECT => Connected, PIN => 27);
      CONFIG_CPOL := (CPOL => ActiveHIGH);
      FREQUENCY   := (FREQUENCY => M8);
      ENABLE := (ENABLE => Enabled);
   end Initialize;

   procedure Send (B : in out Buffer) is
--  pragma Compile_Time_Error (Byte'Size /= 8, "Byte must be of size 8");
   begin
      TXD_PTR := (PTR => B'Address);
      TXD_MAXCNT := (MAXCNT => B'Length);
      TASK_START := (TSK => Trigger);
      for I in B'Range loop
         while EVENT_ENDTX.EVENT = Clear loop
            pragma Inspection_Point (EVENT_ENDTX);
            exit when TXD_AMOUNT.AMOUNT = TXD_MAXCNT.MAXCNT;
         end loop;
         EVENT_ENDTX.EVENT := Clear;
      end loop;
      TASK_STOP := (TSK => Trigger);
   end Send;

   procedure Receive is
   begin
      null;
   end Receive;

end Spi;
