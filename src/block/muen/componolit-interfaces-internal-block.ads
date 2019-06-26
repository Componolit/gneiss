
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Musinfo;

package Componolit.Interfaces.Internal.Block with
   SPARK_Mode
is

   type Response_Cache is array (1 .. Componolit.Interfaces.Muen_Block.Element_Count * 2) of
      Componolit.Interfaces.Muen_Block.Event;

   type Client_Session is limited record
      Name            : Componolit.Interfaces.Muen_Block.Session_Name;
      Count           : Componolit.Interfaces.Muen_Block.Count;
      Request_Memory  : Musinfo.Memregion_Type;
      Response_Memory : Musinfo.Memregion_Type;
      Response_Reader : Componolit.Interfaces.Muen_Block.Client_Response_Channel.Reader_Type;
      Registry_Index  : Componolit.Interfaces.Muen.Session_Index;
      Queued          : Natural;
      Responses       : Response_Cache;
   end record;

   type Request_Status is (Raw, Allocated, Pending, Ok, Error);

   type Client_Request is limited record
      Status : Request_Status;
      Event  : Componolit.Interfaces.Muen_Block.Event;
   end record;

   type Dispatcher_Session is null record;
   type Server_Session is null record;
   type Client_Instance is new Componolit.Interfaces.Muen_Block.Session_Name;
   type Dispatcher_Instance is new Componolit.Interfaces.Muen.Session_Index;
   type Server_Instance is new Componolit.Interfaces.Muen_Block.Session_Name;

   type Dispatcher_Capability is limited record
      Name   : Componolit.Interfaces.Muen_Block.Session_Name;
      Status : Componolit.Interfaces.Muen_Block.Connection_Status;
   end record;

end Componolit.Interfaces.Internal.Block;
