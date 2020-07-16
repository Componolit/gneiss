with Spi;

package body ST7789 is

   procedure Write_Data_CMD (Cmd : Command; D : Data) is
      --  pragma Compile_Time_Error (D'Size /= 8, "Data must be of size 8");
      type CommandArray is array (Natural range <>) of Command;
      type DataArray is array (Natural range <>) of Data;
      CmdArray  : CommandArray (0 .. 0) := (0 => Cmd);
      DtaArray : DataArray (0 .. 0)     := (0 => D);
      procedure Send is new Spi.Send (Command, Natural, CommandArray);
      procedure Data_Send is new Spi.Send (Data, Natural, DataArray);
   begin
      GPIO.Write (CS_PIN, GPIO.Low);
      GPIO.Write (DC_PIN, GPIO.Low);
      Send (CmdArray);
      GPIO.Write (DC_PIN, GPIO.High);
      Data_Send (DtaArray);
      GPIO.Write (CS_PIN, GPIO.High);
   end Write_Data_CMD;

   procedure Write_Data is new Write_Data_CMD (CTL);
   procedure Write_Color_Mode is new Write_Data_CMD (Color_Mode);
   --  procedure Write_Color is new Write_Data_CMD (Color);

   procedure Initialize is
   begin
      GPIO.Configure (CS_PIN, GPIO.Port_Out);
      GPIO.Configure (DC_PIN, GPIO.Port_Out);
      Write_CMD (SLPOUT);
      Write_Color_Mode (COLMOD, RGB565);
      Write_Data (MADCTL, MLRGB);
      Write_CMD (INVON);
      Write_CMD (NORON);
      Write_CMD (DISPON);
   end Initialize;

   procedure Write_CMD (Cmd : Command) is
      type CommandArray is array (Natural range <>) of Command;
      CmdArray : CommandArray (0 .. 0) := (0 => Cmd);
      procedure Send is new Spi.Send (Command, Natural, CommandArray);
   begin
      GPIO.Write (CS_PIN, GPIO.Low);
      GPIO.Write (DC_PIN, GPIO.Low);
      Send (CmdArray);
      GPIO.Write (CS_PIN, GPIO.High);
   end Write_CMD;

   --  procedure Set_Window (X0 : Integer; Y0 : Integer; X1 : Integer; Y1 : Integer) is
   --
   --     type BufX is Array (1 .. 4) of Data;
   --     type BufY is Array (1 .. 4) of Data;
   --
   --  begin
   --     if X0 > X1 and x1 > Display.WIDTH then
   --        return;
   --     end if;
   --     if Y0 > Y1 and Y1 > Display.HEIGHT then
   --        return;
   --     end if;
   --     --  BufX := (
   --     Write_Data_CMD (CASET, BufX);
   --     Write_Data_CMD (RASET, BufY);
   --     Write_CMD (RAMWR);
   --  end Set_Window;
   --
   --  procedure Fill_Color_Buffer (C : Color; L : Integer) is
   --     Buffer_Pixel : constant Integer := 128;
   --     Chunks       : Integer          := Length / Buffer_Pixel;
   --     Rest         : Integer          := Length mod Buffer_Pixel;
   --  begin
   --     null;
   --  end Fill_Color_Buffer;
   --
   --  procedure Fill_Rect (X : Integer; Y : Integer; C : Color) is
   --     W : Integer := Display.WIDTH;
   --     H : Integer := Display.HEIGHT;
   --  begin
   --     Set_Window (X, Y, (X + W - 1), (Y + H - 1));
   --     GPIO.Write (DC_PIN, GPIO.High);
   --     GPIO.Write (CS_PIN, GPIO.Low);
   --     Fill_Color_Buffer (C, (W * H));
   --     GPIO.Write (CS_PIN, GPIO.High);
   --  end Fill_Rect;

end ST7789;
