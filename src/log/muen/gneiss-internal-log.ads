
with Musinfo;
with Debuglog.Types;

package Gneiss.Internal.Log with
   SPARK_Mode
is

   type Client_Session is limited record
      Name   : Musinfo.Name_Type            := Musinfo.Null_Name;
      Mem    : Musinfo.Memregion_Type       := Musinfo.Null_Memregion;
      Index  : Debuglog.Types.Message_Index := Debuglog.Types.Message_Index'First;
      Buffer : Debuglog.Types.Data_Type     := Debuglog.Types.Null_Data;
   end record;

end Gneiss.Internal.Log;
