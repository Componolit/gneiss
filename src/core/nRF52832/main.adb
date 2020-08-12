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

   procedure Rainbow (Color : Output.Pixel; Line : Natural);
   procedure Rainbow (Color : Output.Pixel; Line : Natural) is
   begin
      for I in Line .. Line + 39 loop
         Output.Render (I, 0, 1, 120, (1 .. 120 => Color));
         Output.Render (I, 120, 1, 120, (1 .. 120 => Color));
      end loop;
   end Rainbow;

   Red    : constant Output.Pixel := (255, 0, 24);
   Orange : constant Output.Pixel := (255, 165, 44);
   Yellow : constant Output.Pixel := (255, 255, 65);
   Green  : constant Output.Pixel := (0, 128, 24);
   Blue   : constant Output.Pixel := (0, 0, 249);
   Purple : constant Output.Pixel := (134, 0, 125);

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
   for I in 0 .. 23 loop
      for J in 0 .. 23 loop
         Output.Render (I * 10, J * 10, 10, 10,
                        (1 .. 100 => (Output.Color (J * 10),
                                      Output.Color ((I + J) * 5),
                                      Output.Color (I * 10))));
      end loop;
   end loop;
   Rainbow (Red, 0);
   Rainbow (Orange, 40);
   Rainbow (Yellow, 80);
   Rainbow (Green, 120);
   Rainbow (Blue, 160);
   Rainbow (Purple, 200);
   Debug.Log_Debug ("There should be a Pixel");
   --  Output.Turn_Off;
end Main;
