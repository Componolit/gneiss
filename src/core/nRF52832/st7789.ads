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

   subtype Color is Interfaces.Unsigned_8;

   type Pixel is record
      Red   : Color;
      Green : Color;
      Blue  : Color;
   end record;

   procedure Turn_Off;

   type Frame is array (Positive range <>) of Pixel;

   procedure Render (X : Natural; Y : Natural; Width : Positive; Height : Positive;
                     Window : Frame) with
     Pre => X <= 240
     and then Y <= 240
     and then X + Width - 1 <= 240
     and then Y + Height - 1 <= 240
     and then Window'Length = Width * Height;

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

   type Display_Size is range 0 .. 240;
   subtype Display_Index is Display_Size range 0 .. 239;

   procedure Set_Window (X0 : Display_Index;
                         Y0 : Display_Index;
                         X1 : Display_Index;
                         Y1 : Display_Index) with
     Pre => X0 <= 240
     and then X1 <= 240
     and then X0 <= X1
     and then Y0 <= 240
     and then Y1 <= 240
     and then Y0 <= Y1;

   procedure Hard_Reset;

   procedure Soft_Reset;

   type Display is record
      WIDTH  : Display_Size;
      HEIGHT : Display_Size;
      XSTART : Display_Index;
      YSTART : Display_Index;
   end record;

   subtype Byte is Interfaces.Unsigned_8;
   type Data_Buffer is array (Positive range <>) of Byte;

   function Color_To_Byte (A : Frame) return Data_Buffer;

end ST7789;
