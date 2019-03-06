with Ada.Unchecked_Conversion;
with Cai.Block;
with Cai.Block.Server;
with Cxx.Genode;
with Cai.Component;
use all type Cxx.Genode.Uint64_T;

package body Cxx.Block.Server is

   function Convert_Request (R : Cxx.Block.Request.Class) return Cai.Block.Request
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Uid_Type, Cai.Block.Private_Data);
      Req : Cai.Block.Request ((case R.Kind is
                     when None => Cai.Block.None,
                     when Read => Cai.Block.Read,
                     when Write => Cai.Block.Write));
   begin
      Req.Priv := Convert_Uid (R.Uid);
      case Req.Kind is
         when Cai.Block.None =>
            null;
         when Cai.Block.Read | Cai.Block.Write =>
            Req.Start := Cai.Block.Id (R.Start);
            Req.Length := Cai.Block.Count (R.Length);
            Req.Status := (case R.Status is
               when Raw => Cai.Block.Raw,
               when Ok => Cai.Block.Ok,
               when Error => Cai.Block.Error,
               when Ack => Cai.Block.Acknowledged);
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
                     when Cai.Block.None => None,
                     when Cai.Block.Read => Read,
                     when Cai.Block.Write => Write);
      Req.Uid := Convert_Uid (R.Priv);
      case R.Kind is
         when Cai.Block.None =>
            Req.Start := 0;
            Req.Length := 0;
            Req.Status := Ok;
         when Cai.Block.Read | Cai.Block.Write =>
            Req.Start := Cxx.Genode.Uint64_T (R.Start);
            Req.Length := Cxx.Genode.Uint64_T (R.Length);
            Req.Status := (case R.Status is
               when Cai.Block.Raw => Raw,
               when Cai.Block.Ok => Ok,
               when Cai.Block.Error => Error,
               when Cai.Block.Acknowledged => Ack);
      end case;
      return Req;
   end Convert_Request;

   procedure Ack (D : in out Cai.Component.Block_Server_Device; R : Cai.Block.Request; C : Cai.Block.Context)
   is
      This : constant Class := (Session => Cxx.Void_Address (C), State => D'Address);
      Req : Cxx.Block.Request.Class := Convert_Request (R);
   begin
      Acknowledge (This, Req);
   end Ack;

   package Server_Component is new Cai.Block.Server (Ack);

   procedure Initialize (This : Class; Label : Cxx.Void_Address; Length : Cxx.Genode.Uint64_T)
   is
      Lbl : String(1 .. Integer(Length))
      with Address => Label;
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
   begin
      Server_Component.Initialize (Dev, Lbl, Cai.Block.Context (This.Session));
   end Initialize;

   procedure Finalize (This : Class) is
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
   begin
      Server_Component.Finalize (Dev);
   end Finalize;

   function Block_Count (This : Class) return Cxx.Genode.Uint64_T is
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
   begin
      return Cxx.Genode.Uint64_T (Server_Component.Block_Count (Dev));
   end Block_Count;

   function Block_Size (This : Class) return Cxx.Genode.Uint64_T is
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
   begin
      return Cxx.Genode.Uint64_T (Server_Component.Block_Size (Dev));
   end Block_Size;

   function Writable (This : Class) return Cxx.Bool is
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
   begin
      if Server_Component.Writable (Dev) then
         return 1;
      else
         return 0;
      end if;
   end Writable;

   function Maximal_Transfer_Size (This : Class) return Cxx.Genode.Uint64_T is
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
   begin
      return Cxx.Genode.Uint64_T (Server_Component.Maximal_Transfer_Size (Dev));
   end Maximal_Transfer_Size;

   procedure Read (This : Class;
                   Buffer : Cxx.Void_Address;
                   Size : Cxx.Genode.Uint64_T;
                   Req : in out Cxx.Block.Request.Class) is
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
      R : Cai.Block.Request := Convert_Request (Req);
   begin
      Server_Component.Read (Dev, Buffer, Cai.Block.Unsigned_Long (Size), R);
      Req := Convert_Request (R);
   end Read;

   procedure Write (This : Class;
                    Buffer : Cxx.Void_Address;
                    Size : Cxx.Genode.Uint64_T;
                    Req : in out Cxx.Block.Request.Class) is
      Data : Cai.Block.Buffer (1 .. Cai.Block.Unsigned_Long (Size))
      with Address => Buffer;
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
      R : Cai.Block.Request := Convert_Request (Req);
   begin
      Server_Component.Write (Dev, Data, R);
      Req := Convert_Request (R);
   end Write;

   procedure Sync (This : Class) is
      Dev : Cai.Component.Block_Server_Device
      with Address => This.State;
      pragma Import (C, Dev);
   begin
      Server_Component.Sync (Dev);
   end Sync;

   function State_Size return Cxx.Genode.Uint64_T
   is
   begin
      return Cxx.Genode.Uint64_T (Cai.Component.Block_Server_Device'Size / 8);
   end State_Size;

end Cxx.Block.Server;
