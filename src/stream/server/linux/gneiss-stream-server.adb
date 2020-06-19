with Gneiss_Internal.Stream_Session;

package body Gneiss.Stream.Server with
   SPARK_Mode
is

   package Stream_Session is new Gneiss_Internal.Stream_Session (Buffer_Index, Byte, Buffer);

   procedure Send (Session : in out Server_Session;
                   Data    :        Buffer;
                   Sent    :    out Natural;
                   Ctx     :        Context)
   is
      pragma Unreferenced (Ctx);
   begin
      Stream_Session.Write (Session.Fd, Data, Sent);
   end Send;

end Gneiss.Stream.Server;
