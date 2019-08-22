
private with Componolit.Gneiss.Internal.Rom;

package Componolit.Gneiss.Rom with
   SPARK_Mode
is

   type Client_Session is limited private;

   function Initialized (C : Client_Session) return Boolean;

private

   type Client_Session is new Componolit.Gneiss.Internal.Rom.Client_Session;

end Componolit.Gneiss.Rom;
