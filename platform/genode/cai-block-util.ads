
with Cxx.Block;

generic
   type Instance_Request is private;
   with function Cast_Request (R : Block.Request) return Instance_Request;
   with function Cast_Request (R : Instance_Request) return Block.Request;
package Cai.Block.Util is

   function Convert_Request (I : Instance_Request) return Cxx.Block.Request.Class;
   function Convert_Request (R : Cxx.Block.Request.Class) return Instance_Request;

end Cai.Block.Util;
