
with Componolit.Gneiss.Muen;

package Componolit.Gneiss.Internal.Timer with
   SPARK_Mode
is

   type Client_Session is limited record
      Index : Componolit.Gneiss.Muen.Session_Index := Componolit.Gneiss.Muen.Invalid_Index;
   end record;

end Componolit.Gneiss.Internal.Timer;
