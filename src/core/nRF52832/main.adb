with Sparkfun.Debug;
with Serial;
with Componolit.Runtime.Drivers.GPIO;

procedure Main with
  SPARK_Mode
is
   package GPIO renames Componolit.Runtime.Drivers.GPIO;

   procedure Character_Debug is new Sparkfun.Debug.Debug (Character);
   Str : String := "Hello World";
begin
   Str (Str'First) := 'H';
   GPIO.Configure (18, GPIO.Port_Out);
   GPIO.Write (18, GPIO.Low);
   Sparkfun.Debug.Initialize;
   for C in reverse Character'Val (0) .. Character'Val (10) loop
      for I in Integer range 1 .. 1500000 loop
         pragma Inspection_Point (I);
      end loop;
      Character_Debug (C);

   end loop;

   Serial.Initialize;
   --     loop
   --        for I in Integer range 1 .. 100000 loop
   --           pragma Inspection_Point (I);
   --        end loop;
   --        for I in Integer range 1 .. 1000 loop
   Serial.Print (Str);
   --        end loop;
   loop
      null;
   end loop;
   --     end loop;

end Main;
