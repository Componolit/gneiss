
with Cxx.Genode;
with Cxx.Block.Server;
with Cai.Block.Util;
use all type Cxx.Bool;
use all type Cxx.Genode.Uint64_T;

package body Cai.Block.Server is

   function Cast_Request (R : Request) return Block.Request is
      (Block.Request (R));

   function Cast_Request (R : Block.Request) return Request is
      (Request (R));

   package Util is new Block.Util (Request, Cast_Request, Cast_Request);

   function Create return Server_Session
   is
   begin
      return Server_Session' (Instance => Cxx.Block.Server.Constructor);
   end Create;

   function Get_Instance (S : Server_Session) return Server_Instance
   is
   begin
      return Server_Instance (Cxx.Block.Server.Get_Instance (S.Instance));
   end Get_Instance;

   function Head (S : Server_Session) return Request
   is
   begin
      return Util.Convert_Request (Cxx.Block.Server.Head (S.Instance));
   end Head;

   procedure Discard (S : in out Server_Session)
   is
   begin
      Cxx.Block.Server.Discard (S.Instance);
   end Discard;

   procedure Read (S : in out Server_Session; R : Request; B : Buffer)
   is
   begin
      Cxx.Block.Server.Read (S.Instance, Util.Convert_Request (R), B'Address);
   end Read;

   procedure Write (S : in out Server_Session; R : Request; B : out Buffer)
   is
   begin
      Cxx.Block.Server.Write (S.Instance, Util.Convert_Request (R), B'Address);
   end Write;

   procedure Acknowledge (S : in out Server_Session; R : in out Request)
   is
      Req : Cxx.Block.Request.Class := Util.Convert_Request (R);
   begin
      Cxx.Block.Server.Acknowledge (S.Instance, Req);
      R := Util.Convert_Request (Req);
   end Acknowledge;

   function Initialized (S : Server_Session) return Boolean
   is
   begin
      return Cxx.Block.Server.Initialized (S.Instance) = 1;
   end Initialized;

end Cai.Block.Server;
