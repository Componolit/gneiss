with System;
with Gneiss_Internal.Packet_Session;

package body Gneiss.Packet.Server with
   SPARK_Mode
is

   use type System.Address;

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
   begin
      null;
   end Update;

   procedure Read (Session : in out Server_Session;
                   Desc    :        Descriptor;
                   Ctx     : in out Context)
   is
   begin
      null;
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
