
with Ada.Unchecked_Conversion;
with Cxx.Genode;
with Cxx.Block.Server;
use all type Cxx.Bool;
use all type Cxx.Genode.Uint64_T;

package body Cai.Block.Server is

   procedure Initialize (S : in out Server_Session; L : String; C : in out State)
   is
   begin
      Cxx.Block.Server.Initialize (S.Instance,
                                   L'Address,
                                   Cxx.Genode.Uint64_T (L'Length),
                                   Event'Address,
                                   Block_Count'Address,
                                   Block_Size'Address,
                                   Maximal_Transfer_Size'Address,
                                   Writable'Address);
   end Initialize;

   procedure Finalize (S : in out Server_Session)
   is
   begin
      Cxx.Block.Server.Finalize (S.Instance);
   end Finalize;

   function Convert_Request (R : Cxx.Block.Request.Class) return Cai.Block.Request
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Uid_Type, Cai.Block.Private_Data);
      Req : Cai.Block.Request ((case R.Kind is
                     when Cxx.Block.None => Cai.Block.None,
                     when Cxx.Block.Read => Cai.Block.Read,
                     when Cxx.Block.Write => Cai.Block.Write));
   begin
      Req.Priv := Convert_Uid (R.Uid);
      case Req.Kind is
         when Cai.Block.None =>
            null;
         when Cai.Block.Read | Cai.Block.Write =>
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

   function Convert_Request (R : Cai.Block.Request) return Cxx.Block.Request.Class
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Cai.Block.Private_Data, Uid_Type);
      Req : Cxx.Block.Request.Class;
   begin
      Req.Kind := (case R.Kind is
                     when Cai.Block.None => Cxx.Block.None,
                     when Cai.Block.Read => Cxx.Block.Read,
                     when Cai.Block.Write => Cxx.Block.Write);
      Req.Uid := Convert_Uid (R.Priv);
      case R.Kind is
         when Cai.Block.None =>
            Req.Start := 0;
            Req.Length := 0;
            Req.Status := Cxx.Block.Ok;
         when Cai.Block.Read | Cai.Block.Write =>
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

   procedure Next_Request (S : in out Server_Session; R : out Request)
   is
      Req : Cxx.Block.Request.Class;
   begin
      Cxx.Block.Server.Next_Request (S.Instance, Req);
      R := Convert_Request (Req);
   end Next_Request;

   procedure Read (S : in out Server_Session; R : Request; B : out Buffer; Success : out Boolean)
   is
      Succ : Cxx.Bool;
   begin
      Cxx.Block.Server.Read (S.Instance, Convert_Request (R), B'Address, B'Length, Succ);
      Success := Succ = 1;
   end Read;

   procedure Write (S : in out Server_Session; R : Request; B : Buffer; Success : out Boolean)
   is
      Succ : Cxx.Bool;
   begin
      Cxx.Block.Server.Write (S.Instance, Convert_Request (R), B'Address, B'Length, Succ);
      Success := Succ = 1;
   end Write;

   procedure Acknowledge (S : in out Server_Session; R : in out Request)
   is
      Req : Cxx.Block.Request.Class := Convert_Request (R);
   begin
      Cxx.Block.Server.Acknowledge (S.Instance, Req);
      R := Convert_Request (Req);
   end Acknowledge;

end Cai.Block.Server;
