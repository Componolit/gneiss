
with System;
with Gneiss_Internal.Syscall;
with Gneiss_Internal.Client;
with Gneiss_Internal.Util;
with Gneiss_Protocol.Session;

package body Gneiss.Rom.Client with
   SPARK_Mode
is

   function Get_First is new Gneiss_Internal.Util.Get_First (Buffer_Index);
   function Get_Last is new Gneiss_Internal.Util.Get_Last (Buffer_Index);

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Gneiss.Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
      use type Gneiss_Internal.File_Descriptor;
      Fds : Gneiss_Internal.Fd_Array (1 .. 1) := (others => -1);
   begin
      if Initialized (Session) or else Label'Length > 255 then
         return;
      end if;
      Gneiss_Internal.Client.Initialize (Cap.Broker_Fd, Gneiss_Protocol.Session.Rom, Fds, Label);
      if not Gneiss_Internal.Valid (Fds (Fds'First)) then
         return;
      end if;
      Session.Fd := Fds (Fds'First);
      Gneiss_Internal.Syscall.Mmap (Session.Fd, Session.Map, False);
      if Session.Map = System.Null_Address then
         Gneiss_Internal.Syscall.Close (Session.Fd);
         return;
      end if;
      Session.Index      := Session_Index_Option'(Valid => True, Value => Idx);
      Session.Label.Last := Session.Label.Value'First + Label'Length - 1;
      Session.Label.Value (Session.Label.Value'First .. Session.Label.Last) := Label;
   end Initialize;

   procedure Update (Session : in out Client_Session;
                     Ctx     : in out Context)
   is
      Length : constant Integer      := Gneiss_Internal.Syscall.Stat_Size (Session.Fd);
      Last   : constant Buffer_Index := Get_Last (Length);
      First  : constant Buffer_Index := Get_First (Length);
      Buf    : Buffer (First .. Last) with
         Import,
         Address => Session.Map;
   begin
      Read (Session, Buf, Ctx);
   end Update;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if not Initialized (Session) then
         return;
      end if;
      Gneiss_Internal.Syscall.Munmap (Session.Fd, Session.Map);
      Gneiss_Internal.Syscall.Close (Session.Fd);
      Session.Index := Session_Index_Option'(Valid => False);
   end Finalize;

end Gneiss.Rom.Client;
