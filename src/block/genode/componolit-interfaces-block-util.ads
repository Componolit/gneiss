
with Cxx.Block;

generic
   type Instance_Request is private;
   with function Create_Request (Kind   : Componolit.Interfaces.Block.Request_Kind;
                                 Priv   : Componolit.Interfaces.Block.Private_Data;
                                 Start  : Componolit.Interfaces.Block.Id;
                                 Length : Componolit.Interfaces.Block.Count;
                                 Status : Componolit.Interfaces.Block.Request_Status) return Instance_Request;
   with function Get_Kind (R : Instance_Request) return Componolit.Interfaces.Block.Request_Kind;
   with function Get_Priv (R : Instance_Request) return Componolit.Interfaces.Block.Private_Data;
   with function Get_Start (R : Instance_Request) return Componolit.Interfaces.Block.Id;
   with function Get_Length (R : Instance_Request) return Componolit.Interfaces.Block.Count;
   with function Get_Status (R : Instance_Request) return Componolit.Interfaces.Block.Request_Status;
package Componolit.Interfaces.Block.Util is

   function Convert_Request (I : Instance_Request) return Cxx.Block.Request.Class;
   function Convert_Request (R : Cxx.Block.Request.Class) return Instance_Request;

end Componolit.Interfaces.Block.Util;
