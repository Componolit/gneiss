with AUnit.Assertions; use AUnit.Assertions;

package body Permutation.Tests is

   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Permutation");
   end Name;

   procedure Test_Bijectivity (T : in out Aunit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      N : U64;
   begin
      Initialize (Output_Type'Last);
      for I in FIRST .. LAST loop
         N := U64 (I);
         N := Permute (N);
         N := Inverse (N);
         if N /= U64 (I) then
            Assert (N'Img, I'Img, "Inversion failed");
         end if;
      end loop;
   end Test_Bijectivity;

   procedure Test_Completeness (T : in out Aunit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      N : Output_Type;
      type Number_Array_Type is array (Output_Type) of Output_Type;
      N_Array : Number_Array_Type := (others => Output_Type'Val (0));
      Upper : Output_Type := Output_Type'Val (13);
      Expected_Last : Natural := Output_Type'Pos (Upper);
   begin
      Initialize (Upper);
      for I in Output_Type'First .. Upper loop
         if Has_Element then
            Next (N);
            for J in Output_Type'Pos (Output_Type'First) .. Output_Type'Pos (I) - 1 loop
               Assert (N /= N_Array (Output_Type'Val (J)), "Duplicate");
            end loop;
            N_Array (I) := N;
         else
            Assert (Output_Type'Pos (I)'Img, Expected_Last'Img, "Missing elements");
         end if;
      end loop;
      Assert (not Has_Element, "More elements");

      Initialize (Output_Type'Last);
      Assert (Has_Element, "No elements after initialize");
   end Test_Completeness;

   procedure Test_Determinism (T : in out Aunit.Test_Cases.Test_Case'Class) is
      pragma Unreferenced (T);
      N : Output_Type;
   begin
      Initialize (Output_Type'Last);
      if Output_Type'Size = 12 then
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (-99)), "Unexpected value");
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (80)), "Unexpected value");
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (-925)), "Unexpected value");
      elsif Output_Type'Size = 13 then
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (3128)), "Unexpected value");
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (7002)), "Unexpected value");
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (8096)), "Unexpected value");
      elsif Output_Type'Size = 14 then
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (10023)), "Unexpected value");
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (3128)), "Unexpected value");
         Next (N);
         Assert (N'Img, Output_Type'Image (Output_Type'Val (7002)), "Unexpected value");
      else
         Assert (False, "Unexpected Output_Type'Size");
      end if;
   end Test_Determinism;

   procedure Anonymous_Register (T : in out Test;
                                 P : access procedure (T : in out Aunit.Test_Cases.Test_Case'Class);
                                 S : String) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, P, S);
   end Anonymous_Register;

   procedure Register_Tests (T : in out Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Anonymous_Register (T, Test_Bijectivity'Access, "Bijectivity" & Output_Type'Size'Img);
      Anonymous_Register (T, Test_Completeness'Access, "Completeness" & Output_Type'Size'Img);
      Anonymous_Register (T, Test_Determinism'Access, "Determinism" & Output_Type'Size'Img);
   end Register_Tests;

end Permutation.Tests;
