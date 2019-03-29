
with Ada.Unchecked_Conversion;
with Cxx.Genode;
with Cxx.Block.Server;
use all type Cxx.Bool;
use all type Cxx.Genode.Uint64_T;

package body Cai.Block.Server is

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

   function Convert_Request (R : Cxx.Block.Request.Class) return Request
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Uid_Type, Cai.Block.Private_Data);
      Req : Request ((case R.Kind is
                     when Cxx.Block.None => Cai.Block.None,
                     when Cxx.Block.Sync => Cai.Block.Sync,
                     when Cxx.Block.Read => Cai.Block.Read,
                     when Cxx.Block.Write => Cai.Block.Write,
                     when Cxx.Block.Trim => Cai.Block.Trim));
   begin
      Req.Priv := Convert_Uid (R.Uid);
      case Req.Kind is
         when Cai.Block.None | Cai.Block.Sync =>
            null;
         when Cai.Block.Read | Cai.Block.Write | Cai.Block.Trim =>
            Req.Start := Cai.Block.Id (R.Start);
            Req.Length := Cai.Block.Count (R.Length);
            Req.Status := (case R.Status is
               when Cxx.Block.Raw => Cai.Block.Raw,
               when Cxx.Block.Ok => Cai.Block.Ok,
               when Cxx.Block.Error => Cai.Block.Error,
               when Cxx.Block.Ack => Cai.Block.Acknowledged);
      end case;
      return Req;
   end Convert_Request;

   function Convert_Request (R : Request) return Cxx.Block.Request.Class
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Cai.Block.Private_Data, Uid_Type);
      Req : Cxx.Block.Request.Class;
   begin
      Req.Kind := (case R.Kind is
                     when Cai.Block.None => Cxx.Block.None,
                     when Cai.Block.Sync => Cxx.Block.Sync,
                     when Cai.Block.Read => Cxx.Block.Read,
                     when Cai.Block.Write => Cxx.Block.Write,
                     when Cai.Block.Trim => Cxx.Block.Trim);
      Req.Uid := Convert_Uid (R.Priv);
      case R.Kind is
         when Cai.Block.None | Cai.Block.Sync =>
            Req.Start := 0;
            Req.Length := 0;
            Req.Status := Cxx.Block.Ok;
         when Cai.Block.Read | Cai.Block.Write | Cai.Block.Trim =>
            Req.Start := Cxx.Genode.Uint64_T (R.Start);
            Req.Length := Cxx.Genode.Uint64_T (R.Length);
            Req.Status := (case R.Status is
               when Cai.Block.Raw => Cxx.Block.Raw,
               when Cai.Block.Ok => Cxx.Block.Ok,
               when Cai.Block.Error => Cxx.Block.Error,
               when Cai.Block.Acknowledged => Cxx.Block.Ack);
      end case;
      return Req;
   end Convert_Request;

   function Head (S : Server_Session) return Request
   is
   begin
      return Convert_Request (Cxx.Block.Server.Head (S.Instance));
   end Head;

   procedure Discard (S : in out Server_Session)
   is
   begin
      Cxx.Block.Server.Discard (S.Instance);
   end Discard;

   procedure Read (S : in out Server_Session; R : Request; B : Buffer)
   is
   begin
      Cxx.Block.Server.Read (S.Instance, Convert_Request (R), B'Address);
   end Read;

   procedure Write (S : in out Server_Session; R : Request; B : out Buffer)
   is
   begin
      Cxx.Block.Server.Write (S.Instance, Convert_Request (R), B'Address);
   end Write;

   procedure Acknowledge (S : in out Server_Session; R : in out Request)
   is
      Req : Cxx.Block.Request.Class := Convert_Request (R);
   begin
      Cxx.Block.Server.Acknowledge (S.Instance, Req);
      R := Convert_Request (Req);
   end Acknowledge;

   function Initialized (S : Server_Session) return Boolean
   is
   begin
      return Cxx.Block.Server.Initialized (S.Instance) = 1;
   end Initialized;

end Cai.Block.Server;
