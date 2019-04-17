
with Cxx.Genode;
with Cxx.Block.Server;
with Cai.Block.Util;
use all type Cxx.Bool;
use all type Cxx.Genode.Uint64_T;

package body Cai.Block.Server with
   SPARK_Mode => Off
is

   function Create_Request (Kind   : Cai.Block.Request_Kind;
                            Priv   : Cai.Block.Private_Data;
                            Start  : Cai.Block.Id;
                            Length : Cai.Block.Count;
                            Status : Cai.Block.Request_Status) return Request;

   function Create_Request (Kind   : Cai.Block.Request_Kind;
                            Priv   : Cai.Block.Private_Data;
                            Start  : Cai.Block.Id;
                            Length : Cai.Block.Count;
                            Status : Cai.Block.Request_Status) return Request
   is
      R : Request (Kind => (case Kind is
                            when Cai.Block.None  => Cai.Block.None,
                            when Cai.Block.Read  => Cai.Block.Read,
                            when Cai.Block.Write => Cai.Block.Write,
                            when Cai.Block.Sync  => Cai.Block.Sync,
                            when Cai.Block.Trim  => Cai.Block.Trim));
   begin
      R.Priv := Priv;
      case R.Kind is
         when None =>
            null;
         when others =>
            R.Start  := Start;
            R.Length := Length;
            R.Status := Status;
      end case;
      return R;
   end Create_Request;

   function Get_Kind (R : Request) return Cai.Block.Request_Kind is
      (R.Kind);

   function Get_Priv (R : Request) return Cai.Block.Private_Data is
      (R.Priv);

   function Get_Start (R : Request) return Cai.Block.Id is
      (if R.Kind = Cai.Block.None then 0 else R.Start);

   function Get_Length (R : Request) return Cai.Block.Count is
      (if R.Kind = Cai.Block.None then 0 else R.Length);

   function Get_Status (R : Request) return Cai.Block.Request_Status is
      (if R.Kind = Cai.Block.None then Cai.Block.Raw else R.Status);

   package Server_Util is new Block.Util (Request,
                                          Create_Request,
                                          Get_Kind,
                                          Get_Priv,
                                          Get_Start,
                                          Get_Length,
                                          Get_Status);

   function Create return Server_Session
   is
   begin
      return Server_Session'(Instance => Cxx.Block.Server.Constructor);
   end Create;

   function Get_Instance (S : Server_Session) return Server_Instance
   is
   begin
      return Server_Instance (Cxx.Block.Server.Get_Instance (S.Instance));
   end Get_Instance;

   function Head (S : Server_Session) return Request
   is
   begin
      return Server_Util.Convert_Request (Cxx.Block.Server.Head (S.Instance));
   end Head;

   procedure Discard (S : in out Server_Session)
   is
   begin
      Cxx.Block.Server.Discard (S.Instance);
   end Discard;

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer)
   is
   begin
      Cxx.Block.Server.Read (S.Instance,
                             Server_Util.Convert_Request (R),
                             B'Address);
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer)
   is
   begin
      Cxx.Block.Server.Write (S.Instance,
                              Server_Util.Convert_Request (R),
                              B'Address);
   end Write;

   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request)
   is
      Req : Cxx.Block.Request.Class := Server_Util.Convert_Request (R);
   begin
      Cxx.Block.Server.Acknowledge (S.Instance, Req);
      R := Server_Util.Convert_Request (Req);
   end Acknowledge;

   function Initialized (S : Server_Session) return Boolean
   is
   begin
      return Cxx.Block.Server.Initialized (S.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   procedure Unblock_Client (S : in out Server_Session)
   is
   begin
      Cxx.Block.Server.Unblock_Client (S.Instance);
   end Unblock_Client;

end Cai.Block.Server;
