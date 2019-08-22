
private with Componolit.Interfaces.Internal.Rom;

package Componolit.Interfaces.Rom with
   SPARK_Mode
is

   type Client_Session is limited private;

   function Initialized (C : Client_Session) return Boolean;

private

   type Client_Session is new Componolit.Interfaces.Internal.Rom.Client_Session;

end Componolit.Interfaces.Rom;
