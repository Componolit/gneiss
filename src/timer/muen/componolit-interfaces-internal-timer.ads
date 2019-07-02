
with Componolit.Interfaces.Muen;

package Componolit.Interfaces.Internal.Timer with
   SPARK_Mode
is

   type Client_Session is limited record
      Index : Componolit.Interfaces.Muen.Session_Index;
   end record;

end Componolit.Interfaces.Internal.Timer;
