
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Musinfo;

package Componolit.Interfaces.Internal.Block with
   SPARK_Mode
is

   type Private_Data is new Natural;
   Null_Data : constant Private_Data := 0;

   type Client_Session is limited record
      Name            : Componolit.Interfaces.Muen_Block.Session_Name;
      Count           : Componolit.Interfaces.Muen_Block.Count;
      Request_Memory  : Musinfo.Memregion_Type;
      Response_Memory : Musinfo.Memregion_Type;
      Response_Reader : Componolit.Interfaces.Muen_Block.Client_Response_Channel.Reader_Type;
      Registry_Index  : Componolit.Interfaces.Muen.Session_Index;
      Queued          : Natural;
      Latest_Response : Componolit.Interfaces.Muen_Block.Event;
   end record;

   type Dispatcher_Session is limited record
      Registry_Index : Componolit.Interfaces.Muen.Session_Index;
   end record;

   type Server_Session is limited record
      Name               : Componolit.Interfaces.Muen_Block.Session_Name;
      Registry_Index     : Componolit.Interfaces.Muen.Session_Index;
      Request_Memory     : Musinfo.Memregion_Type;
      Request_Reader     : Componolit.Interfaces.Muen_Block.Server_Request_Channel.Reader_Type;
      Response_Memory    : Musinfo.Memregion_Type;
      Queued             : Natural;
      Latest_Request     : Componolit.Interfaces.Muen_Block.Event;
      Latest_Cache_Index : Private_Data;
      Request_Cache      : Componolit.Interfaces.Muen_Block.Block_Cache;
   end record;

   type Client_Instance is new Componolit.Interfaces.Muen_Block.Session_Name;
   type Dispatcher_Instance is new Componolit.Interfaces.Muen.Session_Index;
   type Server_Instance is new Componolit.Interfaces.Muen_Block.Session_Name;

   type Dispatcher_Capability is limited record
      Name   : Componolit.Interfaces.Muen_Block.Session_Name;
      Status : Componolit.Interfaces.Muen_Block.Connection_Status;
   end record;

end Componolit.Interfaces.Internal.Block;
