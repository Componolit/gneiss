
with System;
with Gneiss_Internal;
with Gneiss_Internal.Syscall;
with Gneiss_Internal.Client;
with Gneiss_Protocol.Session;

package body Gneiss.Rom.Client with
   SPARK_Mode
is

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Gneiss.Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
      use type Gneiss_Internal.File_Descriptor;
      Fds : Gneiss_Internal.Fd_Array (1 .. 1) := (others => -1);
   begin
      if Initialized (Session) then
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
      Size  : constant Integer      := Gneiss_Internal.Syscall.Stat_Size (Session.Fd);
      First : constant Buffer_Index := Buffer_Index'First;
      Last  : constant Buffer_Index := Buffer_Index (Long_Integer (First) + Long_Integer (Size - 1));
      Buf   : Buffer (First .. Last) with
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
