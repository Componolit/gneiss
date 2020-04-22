
with Gneiss_Internal.Linker;
with Gneiss_Internal.Epoll;

private package Gneiss_Internal.Linux with
   SPARK_Mode,
   Elaborate_Body,
   Abstract_State => (Linux_State with Part_Of => Gneiss_Internal.Platform_State)
is

   procedure Socketpair (Fd1 : out File_Descriptor;
                         Fd2 : out File_Descriptor) with
      Import,
      Convention    => C,
      External_Name => "gneiss_socketpair",
      Global        => (In_Out => Linux_State);

   procedure Fork (Pid : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_fork",
      Global        => (In_Out => Linux_State);

   procedure Close (Fd : in out File_Descriptor) with
      Import,
      Convention    => C,
      External_Name => "gneiss_close",
      Global        => (In_Out => Linux_State),
      Post          => Fd = -1;

   procedure Waitpid (Pid    :     Integer;
                      Status : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_waitpid",
      Global        => (In_Out => Linux_State);

   procedure Dup (Oldfd :     File_Descriptor;
                  Newfd : out File_Descriptor) with
      Import,
      Convention    => C,
      External_Name => "gneiss_dup",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Oldfd);

   procedure Write_Message (Socket  : File_Descriptor;
                            Message : System.Address;
                            Size    : Integer;
                            Fds     : Fd_Array;
                            Num     : Natural) with
      Import,
      Convention => C,
      External_Name => "gneiss_write_message",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Socket);

   procedure Read_Message (Socket  :     File_Descriptor;
                           Message :     System.Address;
                           Size    :     Integer;
                           Fds     : out Fd_Array;
                           Num     :     Natural;
                           Length  : out Integer;
                           Trunc   : out Integer;
                           Block   :     Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_read_message",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Socket);

   procedure Peek_Message (Socket  :     File_Descriptor;
                           Message :     System.Address;
                           Size    :     Integer;
                           Fds     : out Fd_Array;
                           Num     :     Natural;
                           Length  : out Integer;
                           Trunc   : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_peek_message",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Socket);

   procedure Drop_Message (Socket : File_Descriptor) with
      Import,
      Convention    => C,
      External_Name => "gneiss_drop_message",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Socket);

   procedure Fputs (Str : String) with
      Import,
      Convention    => C,
      External_Name => "gneiss_fputs",
      Global        => (In_Out => Linux_State),
      Pre           => Str (Str'Last) = ASCII.NUL;

   function Get_Pid return Integer with
      Import,
      Convention    => C,
      External_Name => "getpid",
      Global        => (Input => Linux_State);

   procedure Open (Path     :     String;
                   Fd       : out File_Descriptor;
                   Writable :     Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_open",
      Global        => (In_Out => Linux_State),
      Pre           => Path (Path'Last) = ASCII.NUL;

   procedure Memfd_Seal (Fd      :     File_Descriptor;
                         Success : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_memfd_seal",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Fd);

   function Stat_Size (Fd : File_Descriptor) return Integer with
      Import,
      Convention    => C,
      External_Name => "gneiss_fstat_size",
      Global        => (Input => Linux_State),
      Pre           => Valid (Fd);

   procedure Mmap (Fd       :     File_Descriptor;
                   Addr     : out System.Address;
                   Writable :     Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_mmap",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Fd);

   procedure Munmap (Fd   :        File_Descriptor;
                     Addr : in out System.Address) with
      Import,
      Convention    => C,
      External_Name => "gneiss_munmap",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Fd);

   procedure Timerfd_Create (Fd : out File_Descriptor) with
      Import,
      Convention    => C,
      External_Name => "gneiss_timerfd_create",
      Global        => (In_Out => Linux_State);

   procedure Dl_Open (F :     System.Address;
                      H : out Linker.Dl_Handle) with
      Import,
      Convention    => C,
      External_Name => "gneiss_dlopen",
      Global        => (In_Out => Linux_State);

   function Dl_Sym (H : Linker.Dl_Handle;
                    N : System.Address) return System.Address with
      Import,
      Convention    => C,
      External_Name => "gneiss_dlsym",
      Global        => (Input => Linux_State);

   procedure Create (Efd : out Epoll_Fd) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_create",
      Global        => (In_Out => Linux_State);

   procedure Add (Efd     :     Epoll_Fd;
                  Fd      :     File_Descriptor;
                  Index   :     Integer;
                  Success : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_add_fd",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Fd) and then Valid (Efd);

   procedure Add (Efd     :     Epoll_Fd;
                  Fd      :     File_Descriptor;
                  Ptr     :     System.Address;
                  Success : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_add_ptr",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Fd) and then Valid (Efd);

   procedure Remove (Efd     :     Epoll_Fd;
                     Fd      :     File_Descriptor;
                     Success : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_remove",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Fd) and then Valid (Efd);

   procedure Wait (Efd   :     Epoll_Fd;
                   Ev    : out Epoll.Event;
                   Index : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_wait_fd",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Efd);

   procedure Wait (Efd   :     Epoll_Fd;
                   Ev    : out Epoll.Event;
                   Ptr   : out System.Address) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_wait_ptr",
      Global        => (In_Out => Linux_State),
      Pre           => Valid (Efd);

end Gneiss_Internal.Linux;
