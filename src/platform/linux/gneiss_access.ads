
with RFLX.Types;

generic
   Length : RFLX.Types.Length;
package Gneiss_Access with
   SPARK_Mode,
   Elaborate_Body
is

   Ptr : RFLX.Types.Bytes_Ptr;

   generic
      Field : in out String;
      Last  : in out Natural;
   procedure Get (Data : RFLX.Types.Bytes);

   generic
      Field : String;
   procedure Set (Data : out RFLX.Types.Bytes);

end Gneiss_Access;
