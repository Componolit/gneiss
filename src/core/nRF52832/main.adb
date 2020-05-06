with Sparkfun.Debug;
with Serial;

procedure Main with
  SPARK_Mode
    is
   procedure Character_Debug is new Sparkfun.Debug.Debug (Character);
begin
   Sparkfun.Debug.Initialize;
   Character_Debug ('B'); --  42
   Serial.Initialize;
   loop
      for I in Integer range 1 .. 100000 loop
         pragma Inspection_Point (I);
      end loop;
      for I in Integer range 1 .. 1000 loop
         Serial.Print ((1 => Character'First));
      end loop;

   end loop;
end Main;
