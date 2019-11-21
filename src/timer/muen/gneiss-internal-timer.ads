
with Gneiss.Muen;

package Gneiss.Internal.Timer with
   SPARK_Mode
is

   type Client_Session is limited record
      Index : Gneiss.Muen.Session_Index := Gneiss.Muen.Invalid_Index;
   end record;

end Gneiss.Internal.Timer;
