
package body Componolit.Gneiss.Message.Client with
   SPARK_Mode
is

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Gneiss.Types.Capability;
                         L   :        String)
   is
   begin
      null;
   end Initialize;

   function Available (C : CLient_Session) return Boolean is (False);

   procedure Write (C : in out Client_Session;
                    M :        Message;
                    S :    out Boolean)
   is
   begin
      S := False;
   end Write;

   procedure Read (C : in out Client_Session;
                   M :    out Message)
   is
   begin
      null;
   end Read;

end Componolit.Gneiss.Message.Client;
