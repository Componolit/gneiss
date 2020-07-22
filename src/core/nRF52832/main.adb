with Gneiss;
with Serial;
with Componolit.Runtime.Drivers.GPIO;
with Spi;
with ST7789;

procedure Main with
   SPARK_Mode
is
   package GPIO renames Componolit.Runtime.Drivers.GPIO;
   package Output is new ST7789 (12, 13, 14);

   S1 : String (1 .. 128);
   function F (P : Positive) return String;
   function F (P : Positive) return String
   is
      S : constant String (1 .. P) := (others => 'X');
   begin
      return S & ASCII.CR & ASCII.LF;
   end F;
begin
   Spi.Initialize;
   Output.Initialize;
   GPIO.Configure (18, GPIO.Port_Out);
   GPIO.Write (18, GPIO.Low);
   Serial.Initialize;
   Serial.Print (Gneiss.Name & " " & Gneiss.Version & ASCII.CR & ASCII.LF);
   Serial.Print ("Testing memcpy..." & ASCII.CR & ASCII.LF);
   S1 := (others => 'X');
   Serial.Print (S1 & ASCII.CR & ASCII.LF);
   Serial.Print ("Testing secondary stack..." & ASCII.CR & ASCII.LF);
   Serial.Print (F (64));
   Serial.Print ("Finished." & ASCII.CR & ASCII.LF);
   for I in 0 .. 240 loop
      for J in 0 .. 240 loop
         Output.Draw_Pixel (0, 0, (0, 0, 0));
      end loop;
   end loop;
   Serial.Print ("There should be a Pixel" & ASCII.CR & ASCII.LF);
end Main;
