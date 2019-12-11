
with Gneiss.Muen;

package Gneiss_Internal.Timer with
   SPARK_Mode
is

   type Client_Session is limited record
      Index : Gneiss.Muen.Session_Id := Gneiss.Muen.Invalid_Index;
   end record;

end Gneiss_Internal.Timer;
