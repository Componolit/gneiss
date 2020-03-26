
with System;
with Gneiss_Syscall;
with Gneiss.Platform_Client;
with Gneiss_Protocol.Session;

package body Gneiss.Memory.Client with
   SPARK_Mode
is

   procedure Memfd_Create (Name :     String;
                           Size :     Long_Integer;
                           Fd   : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_memfd_create";

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Size    :        Long_Integer;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
      Fds : Gneiss_Syscall.Fd_Array (1 .. 1);
   begin
      if Initialized (Session) then
         return;
      end if;
      Memfd_Create (Label & ASCII.NUL, Size, Session.Fd);
      if Session.Fd < 0 then
         return;
      end if;
      Gneiss_Syscall.Mmap (Session.Fd, Session.Map, 1);
      if Session.Map = System.Null_Address then
         Gneiss_Syscall.Close (Session.Fd);
         return;
      end if;
      Fds (Fds'First) := Session.Fd;
      Platform_Client.Initialize (Cap, Gneiss_Protocol.Session.Memory, Fds, Label);
      if Fds (Fds'First) < 0 then
         Gneiss_Syscall.Munmap (Session.Fd, Session.Map);
         Gneiss_Syscall.Close (Session.Fd);
         return;
      end if;
      Session.Sigfd := Fds (Fds'First);
      Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   procedure Modify (Session : in out Client_Session)
   is
      Last : constant Buffer_Index := Buffer_Index (Gneiss_Syscall.Stat_Size (Session.Fd));
      B    : Buffer (1 .. Last) with
         Import,
         Address => Session.Map;
   begin
      Modify (Session, B);
   end Modify;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if not Initialized (Session) then
         return;
      end if;
      Gneiss_Syscall.Munmap (Session.Fd, Session.Map);
      Gneiss_Syscall.Close (Session.Sigfd);
      Gneiss_Syscall.Close (Session.Fd);
      Session.Index := Session_Index_Option'(Valid => False);
   end Finalize;

end Gneiss.Memory.Client;
