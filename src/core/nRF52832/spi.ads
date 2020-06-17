with Componolit.Runtime.Drivers.GPIO;

package Spi with
   SPARK_Mode
is
   package GPIO renames Componolit.Runtime.Drivers.GPIO;
   procedure Initialize;
   
private
   
   type SPI_CONFIG_CPOL is (ActiveHIGH, ActiveLOW) with
     Size => 1;
   
   for SPI_CONFIG_CPOL use (ActiveHIGH => 0,
                            ActiveLOW  => 1);
   
   type Reg_SPI_CONFIG_CPOL is record
      CPOL : SPI_CONFIG_CPOL;
   end record with
     Size => 1;
   
   type SPI_Enable is (Disabled, Enabled) with
     Size => 4;
   
   for SPI_Enable use (Disabled => 0,
                       Enabled  => 1;)
     
   type Reg_Enable is record
      ENABLE : SPI_Enable;
   end record with
     Size => 4;
   
   type PSEL_SCK_Connected is (Connected, Disconnected) with
     Size => 32;
   
   for PSEL_SCK_Connected use (Connected    => 0,
                               Disconnected => 1);
      
   type Reg_PSEL_SCK is record
      CONNECT : PSEL_SCK_Connected;
      PIN : GPIO.Pin;
   end record with
     Size => 32;
   
   type PSEL_MOSI_Connected is (Connected, Disconnected) with
     Size => 32;
   
   for PSEL_MOSI_Connected use (Connected    => 0,
                                Disconnected => 1);
   
   type Reg_PSEL_MOSI is record
      CONNECT : PSEL_MOSI_Connected;
      PIN : GPIO.Pin;
   end record with
     Size => 32;
   
   type SPI_TXD_Connected is (Connected, Disconnected) with
     Size => 1;
   
   for SPI_TXD_Connected use (Connected    => 0,
                              Disconnected => 1);
   type Reg_SPI_TXD is record
      CONNECT : SPI_TXD_Connected;
   end record with
     Size => 8;
   
   type SPI_Frequency is (K125,K250, K500, M1, M2, M4, M8) with
     Size =>32;
      
   for SPI_Frequency use (K125 => 16#02000000#,
                          K250 => 16#04000000#,
                          K500 => 16#08000000#,
                          M1   => 16#10000000#,
                          M2   => 16#20000000#,
                          M4   => 16#40000000#,
                          M8   => 16#80000000#);
   
   type Reg_SPI_Frequency is record
      FREQUENCY : SPI_Frequency;
   end record with
     Size => 32;   

end Spi;
