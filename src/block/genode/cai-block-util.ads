
with Cxx.Block;

generic
   type Instance_Request is private;
   with function Create_Request (Kind   : Cai.Block.Request_Kind;
                                 Priv   : Cai.Block.Private_Data;
                                 Start  : Cai.Block.Id;
                                 Length : Cai.Block.Count;
                                 Status : Cai.Block.Request_Status) return Instance_Request;
   with function Get_Kind (R : Instance_Request) return Cai.Block.Request_Kind;
   with function Get_Priv (R : Instance_Request) return Cai.Block.Private_Data;
   with function Get_Start (R : Instance_Request) return Cai.Block.Id;
   with function Get_Length (R : Instance_Request) return Cai.Block.Count;
   with function Get_Status (R : Instance_Request) return Cai.Block.Request_Status;
package Cai.Block.Util is

   function Convert_Request (I : Instance_Request) return Cxx.Block.Request.Class;
   function Convert_Request (R : Cxx.Block.Request.Class) return Instance_Request;

end Cai.Block.Util;
