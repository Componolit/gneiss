with System;
with Gneiss_Internal.Packet_Session;
with Gneiss_Internal.Util;

package body Gneiss.Packet.Server with
   SPARK_Mode
is

   use type System.Address;

   function Get_First is new Gneiss_Internal.Util.Get_First (Buffer_Index);
   function Get_Last is new Gneiss_Internal.Util.Get_Last (Buffer_Index);

   function Allocated (Session : Server_Session;
                       Desc    : Descriptor;
                       Ctx     : Context) return Boolean is
      (Desc.Addr /= System.Null_Address);

   function Writable (Session : Server_Session;
                      Desc    : Descriptor;
                      Ctx     : Context) return Boolean is
      (Desc.Writable);

   procedure Allocate (Session : in out Server_Session;
                       Desc    : in out Descriptor;
                       Size    :        Buffer_Index;
                       Idx     :        Descriptor_Index;
                       Ctx     :        Context)
   is
      pragma Unreferenced (Session);
      pragma Unreferenced (Ctx);
   begin
      if Buffer_Index'Pos (Size) < Natural'Pos (Natural'Last) then
         Desc.Size := Natural (Size);
      else
         Desc.Size := Natural'Last;
      end if;
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Allocate (Desc.Addr, Desc.Size);
      Desc.Writable := True;
      Desc.Index    := Idx;
   end Allocate;

   procedure Send (Session : in out Server_Session;
                   Desc    : in out Descriptor;
                   Ctx     :        Context)
   is
      pragma Unreferenced (Ctx);
   begin
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Send (Session.Fd, Desc.Addr, Desc.Size);
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Free (Desc.Addr);
   end Send;

   procedure Receive (Session : in out Server_Session;
                      Desc    : in out Descriptor;
                      Idx     :        Descriptor_Index;
                      Ctx     :        Context)
   is
      pragma Unreferenced (Ctx);
   begin
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Receive (Session.Fd, Desc.Addr, Desc.Size);
      Desc.Writable := False;
      Desc.Index    := Idx;
   end Receive;

   procedure Update (Session : in out Server_Session;
                     Desc    :        Descriptor;
                     Ctx     : in out Context)
   is
      First : constant Buffer_Index := Get_First (Desc.Size);
      Last  : constant Buffer_Index := Get_Last (Desc.Size);
      B     : Buffer (First .. Last) with
         Import,
         Address => Desc.Addr;
   begin
      Generic_Update (Session, Desc.Index, B, Ctx);
   end Update;

   procedure Read (Session : in out Server_Session;
                   Desc    :        Descriptor;
                   Ctx     : in out Context)
   is
      First : constant Buffer_Index := Get_First (Desc.Size);
      Last  : constant Buffer_Index := Get_Last (Desc.Size);
      B     : Buffer (First .. Last) with
         Import,
         Address => Desc.Addr;
   begin
      Generic_Read (Session, Desc.Index, B, Ctx);
   end Read;

   procedure Free (Session : in out Server_Session;
                   Desc    : in out Descriptor;
                   Ctx     :        Context)
   is
      pragma Unreferenced (Session);
      pragma Unreferenced (Ctx);
   begin
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Free (Desc.Addr);
   end Free;

end Gneiss.Packet.Server;
