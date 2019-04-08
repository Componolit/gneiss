generic
   type Output_Type is (<>);
   Rounds : Positive := 3;
   Key_Schedule : Natural := 16#11#;
   Key0 : Natural := 2;
   Key1 : Natural := 3;
   Key2 : Natural := 5;
   Key3 : Natural := 7;
package Permutation with
SPARK_Mode
is
   pragma Compile_Time_Error (Output_Type'Size <= 11, "Output_Type'Size must be at least 12");

   function Initialized return Boolean with
     Ghost;

   procedure Initialize (Upper : Output_Type) with
     Pre => Upper > Output_Type'First,
     Post => Initialized;
   function Has_Element return Boolean;
   procedure Next (Number : out Output_Type) with
     Pre => Has_Element and Initialized;

private

   type U64 is mod 2**64;
   type U32 is mod 2**32;
   type Long_Natural is range 0 .. 2 ** 32;

   type Data_Type is
      record
         L : U32;
         R : U32;
      end record;

   function Next_Size (O : Output_Type) return Natural with
     Post => Next_Size'Result >= 12 and Next_Size'Result <= 64;

   Upper_Bound : Output_Type := Output_Type'First;

   SIZE : Natural := 0;

   FIRST : constant U64 := 0;
   LAST  : U64 := 0;

   M : Long_Natural := 0;

   function Initialized return Boolean is
      (M > 0);

   RNDS : constant U32 := U32 (Rounds);
   KS   : constant U32 := U32 (Key_Schedule);
   K0   : constant U32 := U32 (Key0);
   K1   : constant U32 := U32 (Key1);
   K2   : constant U32 := U32 (Key2);
   K3   : constant U32 := U32 (Key3);

   State        : U64 := FIRST;
   Next_Number  : U64 := 0;
   Next_Found   : Boolean := False;
   Last_Reached : Boolean := False;

   function Permute (Number : U64) return U64 with
     Pre => Number <= LAST and Initialized;
   function Inverse (Number : U64) return U64 with
     Pre => Number <= LAST and Initialized;

end Permutation;
