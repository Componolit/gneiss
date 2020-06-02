
package body Gneiss.Packet.Server.Linux with
   SPARK_Mode
is

   function Get_Fd (Session : Server_Session) return Integer
   is
   begin
      return Integer (Session.Fd);
   end Get_Fd;

end Gneiss.Packet.Server.Linux;
