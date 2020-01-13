
with Gneiss;
with Musinfo;
with Debuglog.Types;
with Gneiss.Muen;

package Gneiss_Internal.Log with
   SPARK_Mode
is

   type Client_Session is limited record
      Name    : Musinfo.Name_Type            := Musinfo.Null_Name;
      Mem     : Musinfo.Memregion_Type       := Musinfo.Null_Memregion;
      Index   : Debuglog.Types.Message_Index := Debuglog.Types.Message_Index'First;
      Buffer  : Debuglog.Types.Data_Type     := Debuglog.Types.Null_Data;
      S_Index : Gneiss.Session_Index         := 0;
      R_Index : Gneiss.Muen.Session_Id       := 0;
   end record;

   type Dispatcher_Session is limited null record;
   type Server_Session is limited null record;
   type Dispatcher_Capability is limited null record;

end Gneiss_Internal.Log;
