with System.Storage_Elements;

package body Sparkfun.Debug with
   SPARK_Mode
is

   package SSE renames System.Storage_Elements;
   procedure Initialize is
   begin
      for Pin of Pins loop
         GPIO.Configure (Pin, GPIO.Port_Out);
      end loop;
   end Initialize;

   procedure Debug (Value : T) is
      Int          : Integer := T'Pos (Value);
      Quotient     : Integer;
      Binary_Array : Value_Array;
   begin
      for B of Binary_Array loop
         B        := (if Int mod 2 = 1 then GPIO.High else GPIO.Low);
         Quotient := Int / 2;
         Int      := Quotient;
      end loop;
      for I in Array_Index'Range loop
         GPIO.Write (Pins (I), Binary_Array (I));
      end loop;
   end Debug;

   -------------------
   -- Debug_Address --
   -------------------

   procedure Debug_Address (Adr : System.Address)
   is
      Address : SSE.Integer_Address := SSE.To_Integer (Adr);
      procedure Address_Debug is new Debug (SSE.Integer_Address);
      use type SSE.Integer_Address;
   begin
      while Address > 0 loop
         Address_Debug (Address);
         Address := Address / 256;
         for I in Integer range 1 .. 10000000 loop
            pragma Inspection_Point (I);
         end loop;
      end loop;
   end Debug_Address;

end Sparkfun.Debug;
