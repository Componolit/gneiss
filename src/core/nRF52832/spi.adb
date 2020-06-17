package body Spi with
SPARK_Mode
is
   package SSE renames System.Storage_Elements;
   use type SSE.Integer_Address;

   Base : constant SSE.Integer_Address := 16#40003000#;

   ENABLE : Reg_Enable with
     Import,
     Address => SSE.To_Address (Base + 16#500#);

   SPI_CONFIG_CPOL : Reg_SPI_CONFIG_CPOL with
     Import,
     Address => SSE.To_Address (Base + 16#554#);

   PSEL_SCK : Reg_PSEL_SCK with
     Import,
     Address => SSE.To_Address (Base + 16#508#);

   PSEL_MOSI : Reg_PSEL_MOSI with
     Import,
     Address => SSE.To_Address (Base + 16#50C#);

   SPI_TXD : Reg_SPI_TXD with
     Import,
     Address => SSE.To_Address (Base + 16#51C#);

   SPI_FREQUENCY : Reg_SPI_Frequency with
     Import,
     Address => SSE.To_Address (Base + 16#524#);

   procedure Initialize is
   begin
      ENABLE := (ENABLE => Disabled);
      GPIO.Configure (26, GPIO.Port_Out);
      GPIO.Write (26, GPIO.High);
      GPIO.Configure (27, GPIO.Port_Out);
      GPIO.Write(27, GPIO.High);
      PSEL_SCK := (CONNECT => Connected, PIN => 26);
      PSEL_MOSI := (CONNECT => Connected, PIN => 27);
      SPI_CONFIG_CPOL := (CPOL => ActiveHIGH);
      SPI_FREQUENCY := (FREQUENCY => M8);
      ENABLE := (ENABLE => Enabled);
   end Initialize;


end Spi;
