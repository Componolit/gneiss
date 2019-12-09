
with Gneiss_Internal.Message;

package body Gneiss.Message.Server with
   SPARK_Mode
is

   function Available (Session : Server_Session) return Boolean is
      (Gneiss_Internal.Message.Peek (Session.Fd) >= Message_Buffer'Length);

   procedure Write (Session : in out Server_Session;
                    Data    :        Message_Buffer) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message.Write (Session.Fd, Data'Address, Data'Length);
   end Write;

   procedure Read (Session : in out Server_Session;
                   Data    :    out Message_Buffer) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message.Read (Session.Fd, Data'Address, Data'Length);
   end Read;

end Gneiss.Message.Server;
