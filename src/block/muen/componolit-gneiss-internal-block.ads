
with Interfaces;
with Componolit.Gneiss.Muen;
with Componolit.Gneiss.Muen_Block;
with Musinfo;

package Componolit.Gneiss.Internal.Block with
   SPARK_Mode
is
   package CI renames Componolit.Gneiss;

   type Read_Select_List is array (Positive range 1 .. CI.Muen_Block.Element_Count) of CI.Muen_Block.Event_Header;
   type Read_Data_List is array (Read_Select_List'Range) of CI.Muen_Block.Raw_Data_Type;

   type Response_Cache is array (1 .. CI.Muen_Block.Element_Count * 2) of CI.Muen_Block.Event;

   type Client_Session is limited record
      Name            : CI.Muen_Block.Session_Name := CI.Muen_Block.Null_Name;
      Count           : CI.Muen_Block.Count        := 0;
      Request_Memory  : Musinfo.Memregion_Type     := Musinfo.Null_Memregion;
      Response_Memory : Musinfo.Memregion_Type     := Musinfo.Null_Memregion;
      Response_Reader : CI.Muen_Block.Client_Response_Channel.Reader_Type
                           := CI.Muen_Block.Client_Response_Channel.Null_Reader;
      Registry_Index  : CI.Muen.Session_Index           := CI.Muen.Invalid_Index;
      Queued          : Natural                         := 0;
      Responses       : Response_Cache                  := (others => CI.Muen_Block.Null_Event);
      Tag             : Standard.Interfaces.Unsigned_32 := 0;
   end record;

   type Request_Status is (Raw, Allocated, Pending, Ok, Error);

   type Dispatcher_Session is limited record
      Registry_Index : CI.Muen.Session_Index := CI.Muen.Invalid_Index;
   end record;

   type Server_Session is limited record
      Name            : CI.Muen_Block.Session_Name := CI.Muen_Block.Null_Name;
      Registry_Index  : CI.Muen.Session_Index      := CI.Muen.Invalid_Index;
      Request_Memory  : Musinfo.Memregion_Type     := Musinfo.Null_Memregion;
      Request_Reader  : CI.Muen_Block.Server_Request_Channel.Reader_Type
                           := CI.Muen_Block.Server_Request_Channel.Null_Reader;
      Response_Memory : Musinfo.Memregion_Type          := Musinfo.Null_Memregion;
      Read_Select     : Read_Select_List                := (others => CI.Muen_Block.Null_Event_Header);
      Read_Data       : Read_Data_List                  := (others => (others => 0));
      Tag             : Standard.Interfaces.Unsigned_32 := 0;
   end record;

   type Client_Request is limited record
      Status  : Request_Status                  := Raw;
      Session : Standard.Interfaces.Unsigned_32 := 0;
      Event   : CI.Muen_Block.Event             := CI.Muen_Block.Null_Event;
   end record;

   type Server_Request is limited record
      Length  : Standard.Interfaces.Unsigned_64 := 0;
      Session : Standard.Interfaces.Unsigned_32 := 0;
      Event   : CI.Muen_Block.Event             := CI.Muen_Block.Null_Event;
   end record;

   type Dispatcher_Capability is limited record
      Name   : CI.Muen_Block.Session_Name;
      Status : CI.Muen_Block.Connection_Status;
   end record;

end Componolit.Gneiss.Internal.Block;
