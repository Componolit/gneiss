
with Interfaces;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Musinfo;

package Componolit.Interfaces.Internal.Block with
   SPARK_Mode
is

   type Read_Select_List is array (Positive range 1 .. Componolit.Interfaces.Muen_Block.Element_Count) of
      Componolit.Interfaces.Muen_Block.Event_Header;
   type Read_Data_List is array (Read_Select_List'Range) of Componolit.Interfaces.Muen_Block.Raw_Data_Type;

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

   type Server_Request is limited record
      Length : Standard.Interfaces.Unsigned_64;
      Event  : Componolit.Interfaces.Muen_Block.Event;
   end record;

   type Dispatcher_Session is record
      Registry_Index : Componolit.Interfaces.Muen.Session_Index;
   end record;

   type Server_Session is limited record
      Name            : Componolit.Interfaces.Muen_Block.Session_Name;
      Registry_Index  : Componolit.Interfaces.Muen.Session_Index;
      Request_Memory  : Musinfo.Memregion_Type;
      Request_Reader  : Componolit.Interfaces.Muen_Block.Server_Request_Channel.Reader_Type;
      Response_Memory : Musinfo.Memregion_Type;
      Read_Select     : Read_Select_List;
      Read_Data       : Read_Data_List;
   end record;

   type Client_Instance is record
      Name : Componolit.Interfaces.Muen_Block.Session_Name;
      Req  : Musinfo.Memregion_Type;
      Resp : Musinfo.Memregion_Type;
      Idx  : Componolit.Interfaces.Muen.Session_Index;
      Cnt  : Componolit.Interfaces.Muen_Block.Count;
   end record;

   type Dispatcher_Instance is new Componolit.Interfaces.Muen.Session_Index;

   type Server_Instance is record
      Name : Componolit.Interfaces.Muen_Block.Session_Name;
      Req  : Musinfo.Memregion_Type;
      Resp : Musinfo.Memregion_Type;
      Idx  : Componolit.Interfaces.Muen.Session_Index;
   end record;

   type Dispatcher_Capability is limited record
      Name   : Componolit.Interfaces.Muen_Block.Session_Name;
      Status : Componolit.Interfaces.Muen_Block.Connection_Status;
   end record;

end Componolit.Interfaces.Internal.Block;
