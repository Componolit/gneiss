with System;
with Gneiss_Internal;
with Gneiss_Protocol.Session;
with Gneiss_Internal.Client;
with Gneiss_Internal.Epoll;
with Gneiss_Internal.Syscall;
with Gneiss_Internal.Packet_Session;

package body Gneiss.Packet.Client with
   SPARK_Mode
is

   use type System.Address;

   function Get_Event_Address (Session : Client_Session) return System.Address;

   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor);
   procedure Session_Error (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor) is null;

   function Event_Cap is new Gneiss_Internal.Create_Event_Cap (Client_Session,
                                                               Client_Session,
                                                               Session_Event,
                                                               Session_Error);

   function Get_Event_Address (Session : Client_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Get_Event_Address;

   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor)
   is
      pragma Unreferenced (Session);
      pragma Unreferenced (Fd);
   begin
      Event;
   end Session_Event;

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
      use type Gneiss_Internal.File_Descriptor;
      Fds     : Gneiss_Internal.Fd_Array (1 .. 1) := (others => -1);
      Success : Boolean;
   begin
      if Initialized (Session) then
         return;
      end if;
      Gneiss_Internal.Client.Initialize (Cap.Broker_Fd, Gneiss_Protocol.Session.Packet, Fds, Label);
      if not Gneiss_Internal.Valid (Fds (Fds'First)) then
         return;
      end if;
      Session.E_Cap := Event_Cap (Session, Session, Fds (Fds'First));
      Gneiss_Internal.Epoll.Add (Cap.Efd, Fds (Fds'First), Get_Event_Address (Session), Success);
      if not Success then
         Gneiss_Internal.Syscall.Close (Fds (Fds'First));
         Gneiss_Internal.Invalidate (Session.E_Cap);
         return;
      end if;
      Session.Fd    := Fds (Fds'First);
      Session.Efd   := Cap.Efd;
      Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
      Ignore_Success : Boolean;
   begin
      if not Initialized (Session) then
         return;
      end if;
      Gneiss_Internal.Epoll.Remove (Session.Efd, Session.Fd, Ignore_Success);
      Gneiss_Internal.Syscall.Close (Session.Fd);
      Gneiss_Internal.Invalidate (Session.E_Cap);
      Session.Index := Session_Index_Option'(Valid => False);
   end Finalize;

   function Allocated (Session : Client_Session;
                       Desc    : Descriptor) return Boolean is
      (Desc.Addr /= System.Null_Address);

   function Writable (Session : Client_Session;
                      Desc    : Descriptor) return Boolean is
      (Desc.Writable);

   procedure Allocate (Session : in out Client_Session;
                       Desc    : in out Descriptor;
                       Size    :        Buffer_Index;
                       Idx     :        Descriptor_Index)
   is
      pragma Unreferenced (Session);
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

   procedure Send (Session : in out Client_Session;
                   Desc    : in out Descriptor)
   is
   begin
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Send (Session.Fd, Desc.Addr, Desc.Size);
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Free (Desc.Addr);
   end Send;

   procedure Receive (Session : in out Client_Session;
                      Desc    : in out Descriptor;
                      Idx     :        Descriptor_Index)
   is
   begin
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Receive (Session.Fd, Desc.Addr, Desc.Size);
      Desc.Writable := False;
      Desc.Index    := Idx;
   end Receive;

   procedure Update (Session : in out Client_Session;
                     Desc    :        Descriptor;
                     Ctx     : in out Context)
   is
   begin
      null;
   end Update;

   procedure Read (Session : in out Client_Session;
                   Desc    :        Descriptor;
                   Ctx     : in out Context)
   is
   begin
      null;
   end Read;

   procedure Free (Session : in out Client_Session;
                   Desc    : in out Descriptor)
   is
      pragma Unreferenced (Session);
   begin
      Gneiss_Internal.Packet_Session.Gneiss_Packet_Free (Desc.Addr);
   end Free;

end Gneiss.Packet.Client;
