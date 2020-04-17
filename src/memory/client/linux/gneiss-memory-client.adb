
with System;
with Gneiss_Syscall;
with Gneiss.Platform_Client;
with RFLX.Session;

package body Gneiss.Memory.Client with
   SPARK_Mode
is

   procedure Memfd_Create (Name :     String;
                           Size :     Long_Integer;
                           Fd   : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_memfd_create";

   function Get_First (Length : Integer) return Buffer_Index;
   function Get_Last (Length : Integer) return Buffer_Index;

   function Get_First (Length : Integer) return Buffer_Index is
      (if Length < 1 then Buffer_Index'First + 1 else Buffer_Index'First);

   function Get_Last (Length : Integer) return Buffer_Index
   is
   begin
      if Length < 1 then
         return Buffer_Index'First;
      end if;
      if Long_Integer (Length) < Long_Integer (Buffer_Index'Last - Buffer_Index'First + 1) then
         return Buffer_Index (Long_Integer (Buffer_Index'First) + Long_Integer (Length) - 1);
      else
         return Buffer_Index'Last;
      end if;
   end Get_Last;

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Size    :        Long_Integer;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
      Fds : Gneiss_Syscall.Fd_Array (1 .. 1) := (others => -1);
   begin
      if
         Initialized (Session)
         or else Label'Length > 255
         or else Label'First > Integer'Last - 255
      then
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
      Platform_Client.Initialize (Cap, RFLX.Session.Memory, Fds, Label);
      if Fds (Fds'First) < 0 then
         Gneiss_Syscall.Munmap (Session.Fd, Session.Map);
         Gneiss_Syscall.Close (Session.Fd);
         return;
      end if;
      Session.Sigfd := Fds (Fds'First);
      Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   procedure Modify (Session : in out Client_Session;
                     Ctx     : in out Context)
   is
      Length : constant Integer      := Gneiss_Syscall.Stat_Size (Session.Fd);
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
      Gneiss_Syscall.Munmap (Session.Fd, Session.Map);
      Gneiss_Syscall.Close (Session.Sigfd);
      Gneiss_Syscall.Close (Session.Fd);
      Session.Index := Session_Index_Option'(Valid => False);
   end Finalize;

end Gneiss.Memory.Client;
