
with Gneiss_Protocol.Types;

generic
   Length : Gneiss_Protocol.Types.Length;
package Gneiss_Access with
   SPARK_Mode,
   Elaborate_Body
is

   Ptr : Gneiss_Protocol.Types.Bytes_Ptr;

   generic
      Field : in out String;
      Last  : in out Natural;
   procedure Get (Data : Gneiss_Protocol.Types.Bytes);

   generic
      Field : String;
   procedure Set (Data : out Gneiss_Protocol.Types.Bytes);

end Gneiss_Access;
