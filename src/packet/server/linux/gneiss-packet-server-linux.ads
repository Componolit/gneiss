
generic
package Gneiss.Packet.Server.Linux with
   SPARK_Mode
is

   function Get_Fd (Session : Server_Session) return Integer with
      Pre  => Initialized (Session),
      Post => Get_Fd'Result > -1;

end Gneiss.Packet.Server.Linux;
