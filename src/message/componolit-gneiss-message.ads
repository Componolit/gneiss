
private with Componolit.Gneiss.Internal.Message;

package Componolit.Gneiss.Message with
   SPARK_Mode
is

   type Client_Session is limited private;

   function Initialized (C : Client_Session) return Boolean;

private

   type Client_Session is new Componolit.Gneiss.Internal.Message.Client_Session;

end Componolit.Gneiss.Message;
