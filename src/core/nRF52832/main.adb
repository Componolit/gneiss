with Sparkfun.Debug;

procedure Main with
  SPARK_Mode
    is
   procedure Character_Debug is new Sparkfun.Debug.Debug (Character);
begin
   Sparkfun.Debug.Initialize;
   Character_Debug ('B'); --  42
end Main;
