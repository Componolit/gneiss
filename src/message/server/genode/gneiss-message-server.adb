
package body Gneiss.Message.Server with
   SPARK_Mode
is

   procedure Send_Signal (Session : in out Server_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss14Message_Server11send_signalEv";

   procedure Send (Session : in out Server_Session;
                   Data    :        Message_Buffer;
                   Ctx     :        Context)
   is
      pragma Unreferenced (Ctx);
   begin
      if Internal.Queue.Count (Session.Cache) < Internal.Queue.Size (Session.Cache) then
         Internal.Queue.Put (Session.Cache, Data);
         Send_Signal (Session);
      end if;
   end Send;

end Gneiss.Message.Server;
