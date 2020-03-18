
package body Gneiss_Access with
   SPARK_Mode => Off
is

   Buffer : aliased RFLX.Types.Bytes (1 .. Length);

   procedure Get (Data : RFLX.Types.Bytes)
   is
      use type RFLX.Types.Length;
      I : Natural := Field'First;
   begin
      for J in Data'Range loop
         Field (I) := Character'Val (RFLX.Types.Byte'Pos (Data (J)));
         exit when I = Field'Last or else J = Data'Last;
         I := I + 1;
      end loop;
      Last := I;
   end Get;

   procedure Set (Data : out RFLX.Types.Bytes)
   is
      use type RFLX.Types.Length;
      I : Natural := Field'First;
   begin
      Data := (others => RFLX.Types.Byte'First);
      for J in Data'Range loop
         Data (J) := RFLX.Types.Byte'Val (Character'Pos (Field (I)));
         exit when I = Field'Last or else J = Data'Last;
         I := I + 1;
      end loop;
   end Set;

begin
   Ptr := Buffer'Unrestricted_Access;
end Gneiss_Access;
