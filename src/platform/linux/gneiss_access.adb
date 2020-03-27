
package body Gneiss_Access with
   SPARK_Mode => Off
is

   Buffer : aliased Gneiss_Protocol.Types.Bytes (1 .. Length);

   procedure Get (Data : Gneiss_Protocol.Types.Bytes)
   is
      use type Gneiss_Protocol.Types.Length;
      I : Natural := Field'First;
   begin
      for J in Data'Range loop
         Field (I) := Character'Val (Gneiss_Protocol.Types.Byte'Pos (Data (J)));
         exit when I = Field'Last or else J = Data'Last;
         I := I + 1;
      end loop;
      Last := I;
   end Get;

   procedure Set (Data : out Gneiss_Protocol.Types.Bytes)
   is
      use type Gneiss_Protocol.Types.Length;
      I : Natural := Field'First;
   begin
      Data := (others => Gneiss_Protocol.Types.Byte'First);
      for J in Data'Range loop
         Data (J) := Gneiss_Protocol.Types.Byte'Val (Character'Pos (Field (I)));
         exit when I = Field'Last or else J = Data'Last;
         I := I + 1;
      end loop;
   end Set;

begin
   Ptr := Buffer'Unrestricted_Access;
end Gneiss_Access;
