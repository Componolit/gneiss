
with Aunit.Assertions;
with Interfaces;

package body Componolit.Gneiss.Strings.Tests
is

   package SI renames Standard.Interfaces;

   procedure Test_Image_Integer (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert ( Image (Integer'(0)), "0",  "Invalid Integer Image");
      Aunit.Assertions.Assert ( Image (Integer'First), "-2147483648",  "Invalid Integer Image");
      Aunit.Assertions.Assert ( Image (Integer'Last), "2147483647",  "Invalid Integer Image");
      Aunit.Assertions.Assert ( Image (Integer'(-42)), "-42",  "Invalid Integer Image");
      Aunit.Assertions.Assert ( Image (Integer'(42)), "42",  "Invalid Integer Image");
   end Test_Image_Integer;

   procedure Test_Image_Natural (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert ( Image (Natural'First), "0",  "Invalid Natural Image");
      Aunit.Assertions.Assert ( Image (Natural'(42)), "42",  "Invalid Natural Image");
      Aunit.Assertions.Assert ( Image (Natural'Last), "2147483647",  "Invalid Natural Image");
   end Test_Image_Natural;

   procedure Test_Image_Long_Integer (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert ( Image (Long_Integer'(0)), "0",  "Invalid Long_Integer Image");
      Aunit.Assertions.Assert ( Image (Long_Integer'Last), "9223372036854775807",  "Invalid Long_Integer Image");
      Aunit.Assertions.Assert ( Image (Long_Integer'First), "-9223372036854775808",  "Invalid Long_Integer Image");
   end Test_Image_Long_Integer;

   procedure Test_Image_Unsigned_8 (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert ( Image (SI.Unsigned_8'First), "0",  "Invalid Unsigned_8 Image");
      Aunit.Assertions.Assert ( Image (SI.Unsigned_8'Last), "255",  "Invalid Unsigned_8 Image");
      Aunit.Assertions.Assert ( Image (SI.Unsigned_8'(42)), "42",  "Invalid Unsigned_8 Image");
   end Test_Image_Unsigned_8;

   procedure Test_Image_Unsigned_64 (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert (Image (SI.Unsigned_64'First), "0",  "Invalid Unsigned_64 Image");
      Aunit.Assertions.Assert (Image (SI.Unsigned_64'(42)), "42",  "Invalid Unsigned_64 Image");
      Aunit.Assertions.Assert (Image (SI.Unsigned_64'Last), "18446744073709551615",  "Invalid Unsigned_64 Image");
   end Test_Image_Unsigned_64;

   procedure Test_Image_Base_2 (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert (Image (SI.Unsigned_64'Last, 2), "1111111111111111111111111111111111111111111111111111111111111111", "Invalid Base 2 Image");
      Aunit.Assertions.Assert (Image (Long_Integer'First, 2), "-1000000000000000000000000000000000000000000000000000000000000000", "Invalid Base 2 Image");
      Aunit.Assertions.Assert (Image (Long_Integer'Last, 2), "111111111111111111111111111111111111111111111111111111111111111", "Invalid Base 2 Image");
      Aunit.Assertions.Assert (Image (Long_Integer'(42), 2), "101010", "Invalid Base 2 Image");
      Aunit.Assertions.Assert (Image (Long_Integer'(-42), 2), "-101010", "Invalid Base 2 Image");
   end Test_Image_Base_2;

   procedure Test_Image_Base_16 (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert (Image (SI.Unsigned_64'First, 16), "0", "Invalid Base 16 Image");
      Aunit.Assertions.Assert (Image (SI.Unsigned_64'(42), 16), "2A", "Invalid Base 16 Image");
      Aunit.Assertions.Assert (Image (SI.Unsigned_64'Last, 16), "FFFFFFFFFFFFFFFF", "Invalid Base 16 Image");
      Aunit.Assertions.Assert (Image (Long_Integer'First, 16), "-8000000000000000", "Invalid Base 16 Image");
      Aunit.Assertions.Assert (Image (Long_Integer'Last, 16), "7FFFFFFFFFFFFFFF", "Invalid Base 16 Image");
      Aunit.Assertions.Assert (Image (Long_Integer'(42), 16, False), "2a", "Invalid Base 16 Image");
   end Test_Image_Base_16;

   procedure Test_Image_Boolean (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert (Image (True), "True",  "Invalid Boolean Image");
      Aunit.Assertions.Assert (Image (False), "False",  "Invalid Boolean Image");
   end Test_Image_Boolean;

   procedure Test_Image_Duration (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
   begin
      Aunit.Assertions.Assert (Image (Duration'(9223372036.0)), "9223372036.000000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(-9223372036.0)), "-9223372036.000000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'Last), "9223372036.000000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'First), "-9223372036.000000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(0.0)), "0.000000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(42.0)), "42.000000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(-42.0)), "-42.000000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(0.123)), "0.123000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(42.123)), "42.123000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(-42.123)), "-42.123000",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(0.000123)), "0.000123",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(42.000123)), "42.000123",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(-42.000123)), "-42.000123",  "Invalid Duration Image");
      Aunit.Assertions.Assert (Image (Duration'(-0.0042)), "-0.004200", "Invalid Duration Image");
   end Test_Image_Duration;

   procedure Register_Tests (T : in out Test_Case)
   is
      use Aunit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Image_Integer'Access, "Test Image Integer");
      Register_Routine (T, Test_Image_Natural'Access, "Test Image Natural");
      Register_Routine (T, Test_Image_Long_Integer'Access, "Test Image Long_Integer");
      Register_Routine (T, Test_Image_Unsigned_8'Access, "Test Image Unsigned_8");
      Register_Routine (T, Test_Image_Unsigned_64'Access, "Test Image Unsigned_64");
      Register_Routine (T, Test_Image_Boolean'Access, "Test Image Boolean");
      Register_Routine (T, Test_Image_Duration'Access, "Test Image Duration");
      Register_Routine (T, Test_Image_Base_2'Access, "Test Image Base 2");
      Register_Routine (T, Test_Image_Base_16'Access, "Test Image Base 16");
   end Register_Tests;

   function Name (T : Test_Case) return Aunit.Message_String
   is
   begin
      return Aunit.Format ("Componolit.Gneiss.Strings");
   end Name;

end Componolit.Gneiss.Strings.Tests;
