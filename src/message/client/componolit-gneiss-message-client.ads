
with Componolit.Gneiss.Types;

generic
   type Message is private;
   with procedure Event;
package Componolit.Gneiss.Message.Client with
   SPARK_Mode
is

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Gneiss.Types.Capability;
                         L   :        String);

   function Available (C : Client_Session) return Boolean;

   procedure Write (C : in out Client_Session;
                    M :        Message;
                    S :    out Boolean);

   procedure Read (C : in out Client_Session;
                   M :    out Message);

end Componolit.Gneiss.Message.Client;
