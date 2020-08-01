with Spi;
with Serial;
package body ST7789 is

   Disp : constant Display := (240, 240, 0, 0);

   procedure Hard_Reset is
   begin
      GPIO.Write (CS_PIN, GPIO.Low);
      GPIO.Write (RST_PIN, GPIO.High);
      GPIO.Write (RST_PIN, GPIO.Low);
      GPIO.Write (RST_PIN, GPIO.High);
      GPIO.Write (CS_PIN, GPIO.High);
   end Hard_Reset;

   procedure Soft_Reset is
   begin
      Write_CMD (SWRESET);
   end Soft_Reset;

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
      GPIO.Configure (RST_PIN, GPIO.Port_Out);
      GPIO.Configure (CS_PIN, GPIO.Port_Out);
      GPIO.Configure (DC_PIN, GPIO.Port_Out);
      Hard_Reset;
      Write_CMD (SLPOUT);
      Write_Color_Mode (COLMOD, RGB565);
      Write_Data (MADCTL, MLRGB);
      Set_Window (0, 240, 0, 240);
      Write_CMD (INVON);
      Write_CMD (NORON);
      Write_CMD (DISPON);
   end Initialize;

   procedure Turn_Off is
   begin
      Write_CMD (DISPOFF);
      GPIO.Write (CS_PIN, GPIO.High);
   end Turn_Off;

   procedure Write_CMD (Cmd     : Command;
                        Stay_On : Boolean := False) is
      type CommandArray is array (Natural range <>) of Command;
      CmdArray : CommandArray (0 .. 0) := (0 => Cmd);
      procedure Send is new Spi.Send (Command, Natural, CommandArray);
   begin
      GPIO.Write (CS_PIN, GPIO.Low);
      GPIO.Write (DC_PIN, GPIO.Low);
      Send (CmdArray);
      if not Stay_On then
         GPIO.Write (CS_PIN, GPIO.High);
      end if;
   end Write_CMD;

   procedure Set_Window (X0 : Integer; Y0 : Integer; X1 : Integer; Y1 : Integer) is
      type Buf is array (Positive range <>) of Byte;
      procedure Send is new Spi.Send (Byte, Positive, Buf);
      Buffer : Buf (1 .. 4);
   begin
      if X0 > X1 or X1 > Disp.WIDTH then
         Serial.Print ("First IF is wrong" & ASCII.CR & ASCII.LF);
         return;
      end if;
      if Y0 > Y1 or Y1 > Disp.HEIGHT then
         Serial.Print ("Second IF is wrong" & ASCII.CR & ASCII.LF);
         return;
      end if;
      --  Serial.Print ("Set_Window" & ASCII.CR & ASCII.LF);
      Buffer := (0, Byte (X0), 0, Byte (X1));
      Write_CMD (CASET, True);
      GPIO.Write (DC_PIN, GPIO.High);
      Send (Buffer);
      Buffer := (0, Byte (Y0), 0, Byte (Y1));
      Write_CMD (RASET, True);
      GPIO.Write (DC_PIN, GPIO.High);
      Send (Buffer);
      Write_CMD (RAMWR);
   end Set_Window;

   function Color_To_Byte (A : Color_Buffer) return Data_Buffer is
      use type Interfaces.Unsigned_8;
      Buf : Data_Buffer (1 .. A'Length * 2);
      I2  : Natural;
   begin
      for I in A'Range loop
         I2 := (I - A'First) * 2 + Buf'First;
         Buf (I2)     := Interfaces.Shift_Left (Interfaces.Unsigned_8 (A (I).Red), 3)
           + Interfaces.Shift_Right (Interfaces.Unsigned_8 (A (I).Green), 3);
         Buf (I2 + 1) := Interfaces.Shift_Left (Interfaces.Unsigned_8 (A (I).Green), 5)
           + Interfaces.Unsigned_8 (A (I).Blue);
      end loop;
      return Buf;
   end Color_To_Byte;

   procedure Draw_Pixel (X : Integer; Y : Integer; C : Color) is
      procedure Send_Color is new Spi.Send (Byte, Positive, Data_Buffer);
      Buffer : Data_Buffer := Color_To_Byte ((1 => C));
   begin
      --  Serial.Print ("Draw_Pixel" & ASCII.CR & ASCII.LF);
      Set_Window (X, Y, X, Y);
      GPIO.Write (DC_PIN, GPIO.High);
      GPIO.Write (CS_PIN, GPIO.Low);
      Send_Color (Buffer);
      GPIO.Write (CS_PIN, GPIO.High);
   end Draw_Pixel;

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
