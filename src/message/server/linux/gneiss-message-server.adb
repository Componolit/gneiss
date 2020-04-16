
with Gneiss_Internal.Message_Syscall;

package body Gneiss.Message.Server with
   SPARK_Mode
is

   procedure Send (Session : in out Server_Session;
                   Data    :        Message_Buffer;
                   Ctx     :        Context) with
      SPARK_Mode => Off
   is
      pragma Unreferenced (Ctx);
   begin
      Gneiss_Internal.Message_Syscall.Write (Session.Fd, Data'Address, Data'Size * 8);
   end Send;

end Gneiss.Message.Server;
