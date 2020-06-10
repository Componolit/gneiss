with Gneiss;
with Serial;
with Componolit.Runtime.Drivers.GPIO;

procedure Main with
   SPARK_Mode
is
   package GPIO renames Componolit.Runtime.Drivers.GPIO;
   S1 : String (1 .. 128);
   function F (P : Positive) return String;
   function F (P : Positive) return String
   is
      S : constant String (1 .. P) := (others => 'X');
   begin
      return S & ASCII.CR & ASCII.LF;
   end F;
begin
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
end Main;
