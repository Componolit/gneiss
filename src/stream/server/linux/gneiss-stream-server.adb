
package body Gneiss.Stream.Server with
   SPARK_Mode
is

   procedure Send (Session : in out Server_Session;
                   Data    :        Buffer;
                   Sent    :    out Natural;
                   Ctx     :        Context)
   is
      pragma Unreferenced (Session);
      pragma Unreferenced (Data);
      pragma Unreferenced (Ctx);
   begin
      Sent := 0;
   end Send;

end Gneiss.Stream.Server;
