package body Sparkfun.Debug is

   procedure Initialize is
   begin
      for Pin of Pins loop
         GPIO.Configure (Pin, GPIO.Port_Out);
      end loop;
   end Initialize;

   procedure Debug (Char : Character) is
      Int : Integer := Character'Pos (Char);
      Quotient : Integer;
      Binary_Array : Value_Array;
   begin
      for B of Binary_Array loop
         B := (if Int mod 2 = 1 then GPIO.High else GPIO.Low);
         Quotient := Int / 2;
         Int := Quotient;
      end loop;
      for I in Array_Index'Range loop
         GPIO.Write (Pins (I), Binary_Array (I));
      end loop;
   end Debug;

end Sparkfun.Debug;
