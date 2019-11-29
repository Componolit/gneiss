
package body Gneiss.Message.Server with
   SPARK_Mode
is

   function Available (Session : Server_Session) return Boolean is (False);

   procedure Write (Session : in out Server_Session;
                    Data    :        Message_Buffer)
   is
   begin
      null;
   end Write;

   procedure Read (Session : in out Server_Session;
                   Data    :    out Message_Buffer)
   is
   begin
      null;
   end Read;

end Gneiss.Message.Server;
