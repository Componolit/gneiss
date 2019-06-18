
with Musinfo;
with Debuglog.Types;

package Componolit.Interfaces.Internal.Log with
   SPARK_Mode
is

   type Client_Session is limited record
      Name   : Musinfo.Name_Type;
      Mem    : Musinfo.Memregion_Type;
      Index  : Debuglog.Types.Message_Index;
      Buffer : Debuglog.Types.Data_Type;
   end record;

end Componolit.Interfaces.Internal.Log;
