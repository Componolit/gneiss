
with System;
with Gneiss_Internal.Syscall;
with Gneiss_Internal.Client;
with Gneiss_Internal.Util;
with Gneiss_Protocol.Session;

package body Gneiss.Memory.Client with
   SPARK_Mode
is

   procedure Memfd_Create (Name :     String;
                           Size :     Long_Integer;
                           Fd   : out Gneiss_Internal.File_Descriptor) with
      Import,
      Convention    => C,
      External_Name => "gneiss_memfd_create",
      Global        => (In_Out => Gneiss_Internal.Platform_State);

   function Get_First is new Gneiss_Internal.Util.Get_First (Buffer_Index);
   function Get_Last is new Gneiss_Internal.Util.Get_Last (Buffer_Index);

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Size    :        Long_Integer;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
      use type Gneiss_Internal.File_Descriptor;
      Fds : Gneiss_Internal.Fd_Array (1 .. 1) := (others => -1);
   begin
      if
         Initialized (Session)
         or else Label'Length > 255
         or else Label'First > Integer'Last - 255
      then
         return;
      end if;
      Memfd_Create (Label & ASCII.NUL, Size, Session.Fd);
      if not Gneiss_Internal.Valid (Session.Fd) then
         return;
      end if;
      Gneiss_Internal.Syscall.Mmap (Session.Fd, Session.Map, True);
      if Session.Map = System.Null_Address then
         Gneiss_Internal.Syscall.Close (Session.Fd);
         return;
      end if;
      Fds (Fds'First) := Session.Fd;
      Gneiss_Internal.Client.Initialize (Cap.Broker_Fd, Gneiss_Protocol.Session.Memory, Fds, Label);
      if Fds (Fds'First) < 0 then
         Gneiss_Internal.Syscall.Munmap (Session.Fd, Session.Map);
         Gneiss_Internal.Syscall.Close (Session.Fd);
         return;
      end if;
      Session.Sigfd := Fds (Fds'First);
      Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   procedure Modify (Session : in out Client_Session;
                     Ctx     : in out Context)
   is
      Length : constant Integer      := Gneiss_Internal.Syscall.Stat_Size (Session.Fd);
      Last   : constant Buffer_Index := Get_Last (Length);
      First  : constant Buffer_Index := Get_First (Length);
      B      : Buffer (First .. Last) with
         Import,
         Address => Session.Map;
   begin
      Generic_Modify (Session, B, Ctx);
   end Modify;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if not Initialized (Session) then
         return;
      end if;
      Gneiss_Internal.Syscall.Munmap (Session.Fd, Session.Map);
      Gneiss_Internal.Syscall.Close (Session.Sigfd);
      Gneiss_Internal.Syscall.Close (Session.Fd);
      Session.Index := Session_Index_Option'(Valid => False);
   end Finalize;

end Gneiss.Memory.Client;
