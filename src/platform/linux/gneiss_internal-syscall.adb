
with Gneiss_Internal.Linux;

package body Gneiss_Internal.Syscall with
   SPARK_Mode
is

   procedure Socketpair (Fd1 : out File_Descriptor;
                         Fd2 : out File_Descriptor)
   is
   begin
      Linux.Socketpair (Fd1, Fd2);
   end Socketpair;

   procedure Fork (Pid : out Integer)
   is
   begin
      Linux.Fork (Pid);
   end Fork;

   procedure Close (Fd : in out File_Descriptor)
   is
   begin
      Linux.Close (Fd);
   end Close;

   procedure Close (Fd : in out Epoll_Fd)
   is
   begin
      Linux.Close (File_Descriptor (Fd));
   end Close;

   procedure Waitpid (Pid    :     Integer;
                      Status : out Integer)
   is
   begin
      Linux.Waitpid (Pid, Status);
   end Waitpid;

   procedure Dup (Oldfd :     File_Descriptor;
                  Newfd : out File_Descriptor)
   is
   begin
      Linux.Dup (Oldfd, Newfd);
   end Dup;

   function Get_Pid return Integer is (Linux.Get_Pid);

   procedure Open (Path     :     String;
                   Fd       : out File_Descriptor;
                   Writable :     Boolean)
   is
   begin
      Linux.Open (Path, Fd, (if Writable then 1 else 0));
   end Open;

   procedure Memfd_Seal (Fd      :     File_Descriptor;
                         Success : out Boolean)
   is
      Result : Integer;
   begin
      Linux.Memfd_Seal (Fd, Result);
      Success := Result = 1;
   end Memfd_Seal;

   function Stat_Size (Fd : File_Descriptor) return Integer is (Linux.Stat_Size (Fd));

   procedure Mmap (Fd       :     File_Descriptor;
                   Addr     : out System.Address;
                   Writable :     Boolean)
   is
   begin
      Linux.Mmap (Fd, Addr, (if Writable then 1 else 0));
   end Mmap;

   procedure Munmap (Fd   :        File_Descriptor;
                     Addr : in out System.Address)
   is
   begin
      Linux.Munmap (Fd, Addr);
   end Munmap;

   procedure Timerfd_Create (Fd : out File_Descriptor)
   is
   begin
      Linux.Timerfd_Create (Fd);
   end Timerfd_Create;

end Gneiss_Internal.Syscall;
