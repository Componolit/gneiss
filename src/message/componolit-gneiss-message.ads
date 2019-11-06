
private with Componolit.Gneiss.Internal.Message;

package Componolit.Gneiss.Message with
   SPARK_Mode
is

   type Writer_Session is limited private;
   type Reader_Session is limited private;

   function Initialized (W : Writer_Session) return Boolean;
   function Initialized (R : Reader_Session) return Boolean;

private

   type Writer_Session is new Componolit.Gneiss.Internal.Message.Writer_Session;
   type Reader_Session is new Componolit.Gneiss.Internal.Message.Reader_Session;

end Componolit.Gneiss.Message;
