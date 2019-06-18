
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Musinfo;

package Componolit.Interfaces.Internal.Block with
   SPARK_Mode
is

   type Private_Data is new Integer;
   Null_Data : constant := 0;

   type Client_Session is limited record
      Name            : Componolit.Interfaces.Muen_Block.Session_Name;
      Count           : Componolit.Interfaces.Muen_Block.Count;
      Request_Memory  : Musinfo.Memregion_Type;
      Registry_Index  : Componolit.Interfaces.Muen.Session_Index;
   end record;

   type Dispatcher_Session is null record;
   type Server_Session is null record;
   type Client_Instance is new Componolit.Interfaces.Muen_Block.Session_Name;
   type Dispatcher_Instance is null record;
   type Server_Instance is null record;

end Componolit.Interfaces.Internal.Block;
