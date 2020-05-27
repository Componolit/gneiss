with Serial;
with Componolit.Runtime.Drivers.GPIO;
with Sparkfun.Debug;

procedure Main with
  SPARK_Mode
is
   package GPIO renames Componolit.Runtime.Drivers.GPIO;
   procedure Debug is new Sparkfun.Debug.Debug (Integer);
   A : String (1 .. 1024);
begin
   GPIO.Configure (18, GPIO.Port_Out);
   GPIO.Write (18, GPIO.Low);
   Sparkfun.Debug.Initialize;
   Serial.Initialize;
   Debug (1);
   Serial.Print ("Hello World!");
   Debug (2);
   for I in A'Range loop
      A (I) := 'A';
   end loop;
   Serial.Print (A);
   Debug (3);
   loop
      null;
   end loop;
end Main;
