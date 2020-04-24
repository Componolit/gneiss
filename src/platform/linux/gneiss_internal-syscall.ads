with System;

package Gneiss_Internal.Syscall with
   SPARK_Mode
is

   procedure Socketpair (Fd1 : out File_Descriptor;
                         Fd2 : out File_Descriptor) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Fork (Pid : out Integer) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Close (Fd : in out File_Descriptor) with
      Post   => not Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Close (Fd : in out Epoll_Fd) with
      Post   => not Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Waitpid (Pid    :     Integer;
                      Status : out Integer) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Dup (Oldfd :     File_Descriptor;
                  Newfd : out File_Descriptor) with
      Pre    => Valid (Oldfd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   function Get_Pid return Integer with
      Global => (Input => Gneiss_Internal.Platform_State);

   procedure Open (Path     :     String;
                   Fd       : out File_Descriptor;
                   Writable :     Boolean) with
      Pre    => (for some C of Path => C = ASCII.NUL),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Memfd_Seal (Fd      :     File_Descriptor;
                         Success : out Boolean) with
      Pre    => Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   function Stat_Size (Fd : File_Descriptor) return Integer with
      Pre    => Valid (Fd),
      Global => (Input => Gneiss_Internal.Platform_State);

   procedure Mmap (Fd       :     File_Descriptor;
                   Addr     : out System.Address;
                   Writable :     Boolean) with
      Pre    => Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Munmap (Fd   :        File_Descriptor;
                     Addr : in out System.Address) with
      Pre    => Valid (Fd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Timerfd_Create (Fd : out File_Descriptor) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   --  This is a dummy procedure to satisfy the global state change for
   --  procedures that do not actually change the global state but are
   --  annotated to do so. The annotation is requierd for platform independence.
   procedure Modify_Platform with
      Global => (In_Out => Gneiss_Internal.Platform_State);

end Gneiss_Internal.Syscall;
