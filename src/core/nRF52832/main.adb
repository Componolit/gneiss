with Gneiss;
with Componolit.Runtime.Drivers.GPIO;
with Componolit.Runtime.Debug;
with Spi;
with ST7789;

procedure Main with
   SPARK_Mode
is
   package GPIO renames Componolit.Runtime.Drivers.GPIO;
   package Debug renames Componolit.Runtime.Debug;
   package Output is new ST7789 (12, 13, 14);

   S1 : String (1 .. 128);
   function F (P : Positive) return String;
   function F (P : Positive) return String
   is
      S : constant String (1 .. P) := (others => 'X');
   begin
      return S;
   end F;
begin
   Spi.Initialize;
   Output.Initialize;
   GPIO.Configure (18, GPIO.Port_Out);
   GPIO.Write (18, GPIO.Low);
   Debug.Log_Debug (Gneiss.Name & " " & Gneiss.Version);
   Debug.Log_Debug ("Testing memcpy...");
   S1 := (others => 'X');
   Debug.Log_Debug (S1);
   Debug.Log_Debug ("Testing secondary stack...");
   Debug.Log_Debug (F (64));
   Debug.Log_Debug ("Finished.");
   for I in 0 .. 239 loop
      for J in 0 .. 239 loop
         Output.Draw_Pixel (I, J, (Output.Color (J), Output.Color (I), Output.Color (J)));
      end loop;
   end loop;
   --  Output.Draw_Pixel (0, 0, (255, 0, 0));
   --  Output.Draw_Pixel (0, 0, (0, 255, 0));
   --  Output.Draw_Pixel (0, 0, (0, 0, 255));
   Debug.Log_Debug ("There should be a Pixel");
   Output.Turn_Off;
end Main;
