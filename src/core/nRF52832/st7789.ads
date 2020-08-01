with Componolit.Runtime.Drivers.GPIO;
with Interfaces;

generic
   pragma Warnings (Off, "formal object * is not referenced");
   CS_PIN  : Componolit.Runtime.Drivers.GPIO.Pin;
   RST_PIN : Componolit.Runtime.Drivers.GPIO.Pin;
   DC_PIN  : Componolit.Runtime.Drivers.GPIO.Pin;
   --   BL_PIN  : GPIO.Pin;
   pragma Warnings (On, "formal object * is not referenced");
package ST7789 with
SPARK_Mode
is
   package GPIO renames Componolit.Runtime.Drivers.GPIO;

   procedure Initialize;

   type Px5 is mod 2 ** 5;

   type Px6 is mod 2 ** 6;

   type Color is record
      Red   : Px5;
      Green : Px6;
      Blue  : Px5;
   end record;

   procedure Draw_Pixel (X : Integer; Y : Integer; C : Color);

   procedure Turn_Off;

private

   type Color_Mode is (RGB565) with
     Size => 8;

   for Color_Mode use (RGB565 => 16#55#);

   type Mode is record
      Mode : Color_Mode;
   end record with
     Size => 8;

   type CTL is (MLRGB) with
     Size => 8;

   for CTL use (MLRGB => 16#10#);

   type Command is (NOP, SWRESET, RDDID, RDDST, SLPIN, SLPOUT, PTLON, NORON,
                    INVOFF, INVON, DISPOFF, DISPON, CASET, RASET, RAMWR, RAMRD,
                    PTLAR, MADCTL, COLMOD, RDID1, RDID2, RDID3, RDID4) with
     Size => 8;

   for Command use (NOP        => 16#00#,
                    SWRESET    => 16#01#,
                    RDDID      => 16#04#,
                    RDDST      => 16#09#,
                    SLPIN      => 16#10#,
                    SLPOUT     => 16#11#,
                    PTLON      => 16#12#,
                    NORON      => 16#13#,
                    INVOFF     => 16#20#,
                    INVON      => 16#21#,
                    DISPOFF    => 16#28#,
                    DISPON     => 16#29#,
                    CASET      => 16#2A#,
                    RASET      => 16#2B#,
                    RAMWR      => 16#2C#,
                    RAMRD      => 16#2E#,
                    PTLAR      => 16#30#,
                    MADCTL     => 16#36#,
                    COLMOD     => 16#3A#,
                    RDID1      => 16#DA#,
                    RDID2      => 16#DB#,
                    RDID3      => 16#DC#,
                    RDID4      => 16#DD#);

   procedure Write_CMD (Cmd     : Command;
                        Stay_On : Boolean := False);

   generic
      type Data is private;
   procedure Write_Data_CMD (Cmd : Command; D : Data);

   procedure Set_Window (X0 : Integer;
                         Y0 : Integer;
                         X1 : Integer;
                         Y1 : Integer);

   procedure Hard_Reset;

   procedure Soft_Reset;

   type Display is record
      WIDTH  : Integer;
      HEIGHT : Integer;
      XSTART : Integer;
      YSTART : Integer;
   end record;

   subtype Byte is Interfaces.Unsigned_8;
   type Data_Buffer is array (Positive range <>) of Byte;
   type Color_Buffer is array (Positive range <>) of Color;

   function Color_To_Byte (A : Color_Buffer) return Data_Buffer;

   --  procedure Fill_Color_Buffer (C : Color;
   --                               L : Integer);
   --  procedure Fill_Rect (X : Integer; Y : Integer; C : Color);

end ST7789;
