
package body Gneiss_Access with
   SPARK_Mode => Off
is

   Data : aliased RFLX.Types.Bytes (1 .. Length);

begin
   Ptr := Data'Unrestricted_Access;
end Gneiss_Access;
