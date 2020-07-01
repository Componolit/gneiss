with Componolit.Runtime.Drivers.GPIO;
with System;

package Spi with
SPARK_Mode
is
   package GPIO renames Componolit.Runtime.Drivers.GPIO;

   procedure Initialize;

   procedure Receive;

   generic
      type Byte is (<>);
      type Index is range <>;
      type Buffer is array (Index range <>) of Byte;

   procedure Send (B : Buffer);

private

   type SPIM_CONFIG_CPOL is (ActiveHIGH, ActiveLOW) with
     Size => 1;

   for SPIM_CONFIG_CPOL use (ActiveHIGH => 0,
                             ActiveLOW  => 1);

   type Reg_SPIM_CONFIG_CPOL is record
      CPOL : SPIM_CONFIG_CPOL;
   end record with
     Size => 32;

   type SPIM_Enable is (Disabled, Enabled) with
     Size => 4;

   for SPIM_Enable use (Disabled  => 0,
                        Enabled   => 7);

   type Reg_Enable is record
      ENABLE : SPIM_Enable;
   end record with
     Size => 32;

   for Reg_Enable use record
      ENABLE at 0 range 0 .. 3;
   end record;

   type Reg_TXD_PTR is record
      PTR : System.Address;
   end record with
     Size => 32;

   type Count is range 0 .. 255 with
     Size => 8;

   type Reg_TXD_MAXCNT is record
      MAXCNT : Count;
   end record with
     Size => 32;

   type Reg_TXD_AMOUNT is record
      AMOUNT : Count;
   end record with
     Size => 32;

   type Reg_RXD_PTR is record
      PTR : System.Address;
   end record with
     Size => 32;

   type Reg_RXD_MAXCNT is record
      MAXCNT : Count;
   end record with
     Size => 32;

   type Reg_RXD_AMOUNT is record
      AMOUNG : Count;
   end record with
     Size => 32;

   type PSEL_SCK_Connected is (Connected, Disconnected) with
     Size => 32;

   for PSEL_SCK_Connected use (Connected    => 0,
                               Disconnected => 1);

   type Reg_PSEL_SCK is record
      CONNECT : PSEL_SCK_Connected;
      PIN     : GPIO.Pin;
   end record with
     Size => 32;

   for Reg_PSEL_SCK use record
      CONNECT at 0 range 31 .. 31;
      PIN at 0 range 0 .. 4;
   end record;

   type PSEL_MOSI_Connected is (Connected, Disconnected) with
     Size => 32;

   for PSEL_MOSI_Connected use (Connected    => 0,
                                Disconnected => 1);

   type Reg_PSEL_MOSI is record
      CONNECT : PSEL_MOSI_Connected;
      PIN     : GPIO.Pin;
   end record with
     Size => 32;

   for Reg_PSEL_MOSI use record
      CONNECT at 0 range 31 .. 31;
      PIN at 0 range 0 .. 4;
   end record;

   type SPIM_Frequency is (K125, K250, K500, M1, M2, M4, M8) with
     Size => 32;

   for SPIM_Frequency use (K125 => 16#02000000#,
                           K250  => 16#04000000#,
                           K500  => 16#08000000#,
                           M1    => 16#10000000#,
                           M2    => 16#20000000#,
                           M4    => 16#40000000#,
                           M8    => 16#80000000#);

   type Reg_SPIM_Frequency is record
      FREQUENCY : SPIM_Frequency;
   end record with
     Size => 32;

   --  for enabling shortcuts
   type SPIM_END_START is (Disabled, Enabled) with
     Size => 1;

   for SPIM_END_START use (Disabled => 0,
                           Enabled  => 1);

   type Reg_END_START is record
      ENABLED : SPIM_END_START;
   end record with
     Size => 32;

   type EVENT_Event is (Clear, Set) with
     Size => 1;

   for EVENT_Event use (Clear => 0,
                        Set   => 1);

   type Reg_EVENT is record
      EVENT : EVENT_Event;
   end record with
     Size => 32;

   for Reg_EVENT use record
      EVENT at 0 range 0 .. 0;
   end record;

   type TASK_Trigger is (Trigger) with
     Size => 1;

   for TASK_Trigger use (Trigger => 1);

   type Reg_TASK is record
      TSK : TASK_Trigger;
   end record with
     Size => 32;

   for Reg_TASK use record
      TSK at 0 range 0 .. 0;
   end record;
end Spi;
