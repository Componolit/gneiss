with Ada.Unchecked_Conversion;
with Block;
with Block.Server;
with Cxx.Genode;
with Component;
use all type Cxx.Genode.Uint64_T;

package body Cxx.Block.Server is

   function Convert_Request (R : Cxx.Block.Request.Class) return Standard.Block.Request
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Uid_Type, Standard.Block.Private_Data);
      Req : Standard.Block.Request ((case R.Kind is
                     when None => Standard.Block.None,
                     when Read => Standard.Block.Read,
                     when Write => Standard.Block.Write,
                     when Sync => Standard.Block.Sync));
   begin
      Req.Priv := Convert_Uid (R.Uid);
      case Req.Kind is
         when Standard.Block.None | Standard.Block.Sync =>
            null;
         when Standard.Block.Read | Standard.Block.Write =>
            Req.Start := Standard.Block.Id (R.Start);
            Req.Length := Standard.Block.Count (R.Length);
            Req.Status := (case R.Status is
               when Raw => Standard.Block.Raw,
               when Ok => Standard.Block.Ok,
               when Error => Standard.Block.Error,
               when Ack => Standard.Block.Acknowledged);
      end case;
      return Req;
   end Convert_Request;

   function Convert_Request (R : Standard.Block.Request) return Cxx.Block.Request.Class
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Standard.Block.Private_Data, Uid_Type);
      Req : Cxx.Block.Request.Class;
   begin
      Req.Kind := (case R.Kind is
                     when Standard.Block.None => None,
                     when Standard.Block.Read => Read,
                     when Standard.Block.Write => Write,
                     when Standard.Block.Sync => Sync);
      Req.Uid := Convert_Uid (R.Priv);
      case R.Kind is
         when Standard.Block.None | Standard.Block.Sync =>
            Req.Start := 0;
            Req.Length := 0;
            Req.Status := Ok;
         when Standard.Block.Read | Standard.Block.Write =>
            Req.Start := Cxx.Genode.Uint64_T (R.Start);
            Req.Length := Cxx.Genode.Uint64_T (R.Length);
            Req.Status := (case R.Status is
               when Standard.Block.Raw => Raw,
               when Standard.Block.Ok => Ok,
               when Standard.Block.Error => Error,
               when Standard.Block.Acknowledged => Ack);
      end case;
      return Req;
   end Convert_Request;

   procedure Ack (D : in out Component.Block_Device; R : Standard.Block.Request; C : Standard.Block.Context)
   is
      This : Class := (Session => Cxx.Void_Address (C), State => D'Address);
      Req : Cxx.Block.Request.Class := Convert_Request (R);
   begin
      Acknowledge (This, Req);
   end Ack;

   package Server_Component is new Standard.Block.Server (Ack);

   procedure Initialize (This : in out Class; Label : Cxx.Void_Address; Length : Cxx.Genode.Uint64_T)
   is
      Lbl : String(1 .. Integer(Length))
      with Address => Label;
      Dev : Component.Block_Device
      with Address => This.State;
   begin
      Server_Component.Initialize (Dev, Lbl, Standard.Block.Context (This.Session));
   end Initialize;

   procedure Finalize (This : in out Class) is
      Dev : Component.Block_Device
      with Address => This.State;
   begin
      Server_Component.Finalize (Dev);
   end Finalize;

   function Block_Count (This : Class) return Cxx.Genode.Uint64_T is
      Dev : Component.Block_Device
      with Address => This.State;
   begin
      return Cxx.Genode.Uint64_T (Server_Component.Block_Count (Dev));
   end Block_Count;

   function Block_Size (This : Class) return Cxx.Genode.Uint64_T is
      Dev : Component.Block_Device
      with Address => This.State;
   begin
      return Cxx.Genode.Uint64_T (Server_Component.Block_Size (Dev));
   end Block_Size;

   function Writable (This : Class) return Cxx.Bool is
      Dev : Component.Block_Device
      with Address => This.State;
   begin
      if Server_Component.Writable (Dev) then
         return 1;
      else
         return 0;
      end if;
   end Writable;

   function Maximal_Transfer_Size (This : Class) return Cxx.Genode.Uint64_T is
      Dev : Component.Block_Device
      with Address => This.State;
   begin
      return Cxx.Genode.Uint64_T (Server_Component.Maximal_Transfer_Size (Dev));
   end Maximal_Transfer_Size;

   procedure Read (This : Class;
                   Buffer : Cxx.Void_Address;
                   Size : Cxx.Genode.Uint64_T;
                   Req : in out Cxx.Block.Request.Class) is
      Data : Standard.Block.Buffer (1 .. Standard.Block.Unsigned_Long (Size))
      with Address => Buffer;
      Dev : Component.Block_Device
      with Address => This.State;
      R : Standard.Block.Request := Convert_Request (Req);
   begin
      Server_Component.Read (Dev, Data, R);
      Req := Convert_Request (R);
   end Read;

   procedure Sync (This : Class; Req : in out Cxx.Block.Request.Class) is
      Dev : Component.Block_Device
      with Address => This.State;
      R : Standard.Block.Request := Convert_Request (Req);
   begin
      Server_Component.Sync (Dev, R);
      Req := Convert_Request (R);
   end Sync;

   procedure Write (This : Class;
                    Buffer : Cxx.Void_Address;
                    Size : Cxx.Genode.Uint64_T;
                    Req : in out Cxx.Block.Request.Class) is
      Data : Standard.Block.Buffer (1 .. Standard.Block.Unsigned_Long (Size))
      with Address => Buffer;
      Dev : Component.Block_Device
      with Address => This.State;
      R : Standard.Block.Request := Convert_Request (Req);
   begin
      Server_Component.Write (Dev, Data, R);
      Req := Convert_Request (R);
   end Write;

   function State_Size return Cxx.Genode.Uint64_T
   is
   begin
      return Cxx.Genode.Uint64_T (Component.Block_Device'Size / 8);
   end State_Size;

end Cxx.Block.Server;
