with Spi;
with Componolit.Runtime.Debug;
package body ST7789 is

   package Debug renames Componolit.Runtime.Debug;
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
      Set_Window (0, 239, 0, 239);
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

   procedure Set_Window (X0 : Display_Index; Y0 : Display_Index;
                         X1 : Display_Index; Y1 : Display_Index) is
      type Buf is array (Positive range <>) of Byte;
      procedure Send is new Spi.Send (Byte, Positive, Buf);
      Buffer : Buf (1 .. 4);
   begin
      if X0 > X1 or X1 > Disp.WIDTH then
         Debug.Log_Debug ("First IF is wrong" & ASCII.CR & ASCII.LF);
         return;
      end if;
      if Y0 > Y1 or Y1 > Disp.HEIGHT then
         Debug.Log_Debug ("Second IF is wrong" & ASCII.CR & ASCII.LF);
         return;
      end if;
      --  Debug.Log_Debug ("Set_Window" & ASCII.CR & ASCII.LF);
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

   function Color_To_Byte (A : Frame) return Data_Buffer is
      use type Interfaces.Unsigned_8;
      Buf : Data_Buffer (1 .. A'Length * 2);
      I2  : Natural;
   begin
      for I in A'Range loop
         I2 := (I - A'First) * 2 + Buf'First;
         Buf (I2)     := (A (I).Red and 16#F8#) + Interfaces.Shift_Right (A (I).Green, 5);
         Buf (I2 + 1) := (Interfaces.Shift_Left (A (I).Green, 3) and 16#E0#)
           + Interfaces.Shift_Right (A (I).Blue, 3);
      end loop;
      return Buf;
   end Color_To_Byte;

   procedure Render (X : Natural; Y : Natural; Width : Positive;
                     Height : Positive; Window : Frame) is
      Buffer : Data_Buffer := Color_To_Byte (Window);
      procedure Render_Send is new Spi.Send (Byte, Positive, Data_Buffer);
   begin
      Set_Window (Display_Index (X), Display_Index (Y),
                  Display_Index (X + Width - 1), Display_Index (Y + Height - 1));
      GPIO.Write (DC_PIN, GPIO.High);
      GPIO.Write (CS_PIN, GPIO.Low);
      Render_Send (Buffer);
      GPIO.Write (CS_PIN, GPIO.High);
   end Render;

end ST7789;
