
with System;

package Gneiss_Syscall with
   SPARK_Mode,
   Abstract_State => Linux,
   Initializes    => Linux,
   Elaborate_Body
is

   type Fd_Array is array (Natural range <>) of Integer;

   procedure Socketpair (Fd1 : out Integer;
                         Fd2 : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_socketpair",
      Global        => (In_Out => Linux);

   procedure Fork (Pid : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_fork",
      Global        => (In_Out => Linux);

   procedure Close (Fd : in out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_close",
      Global        => (In_Out => Linux),
      Post          => Fd = -1;

   procedure Waitpid (Pid : Integer;
                      Status : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_waitpid",
      Global        => (In_Out => Linux);

   procedure Dup (Oldfd :     Integer;
                  Newfd : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_dup",
      Global        => (In_Out => Linux);

   procedure Write_Message (Socket  : Integer;
                            Message : System.Address;
                            Size    : Integer;
                            Fds     : Fd_Array;
                            Num     : Natural) with
      Import,
      Convention => C,
      External_Name => "gneiss_write_message",
      Global        => (In_Out => Linux);

   procedure Read_Message (Socket  :     Integer;
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
      Global        => (In_Out => Linux);

   procedure Peek_Message (Socket  :     Integer;
                           Message :     System.Address;
                           Size    :     Integer;
                           Fds     : out Fd_Array;
                           Num     :     Natural;
                           Length  : out Integer;
                           Trunc   : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_peek_message",
      Global        => (In_Out => Linux);

   procedure Drop_Message (Socket : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_drop_message",
      Global        => (In_Out => Linux);

   procedure Fputs (Str : String) with
      Import,
      Convention    => C,
      External_Name => "gneiss_fputs",
      Global        => (In_Out => Linux),
      Pre           => Str (Str'Last) = ASCII.NUL;

   function Get_Pid return Integer with
      Import,
      Convention    => C,
      External_Name => "getpid",
      Global        => (Input => Linux);

   procedure Open (Path     :     String;
                   Fd       : out Integer;
                   Writable :     Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_open",
      Global        => (In_Out => Linux),
      Pre           => Path (Path'Last) = ASCII.NUL;

   procedure Memfd_Seal (Fd      :     Integer;
                         Success : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_memfd_seal",
      Global        => (In_Out => Linux);

   function Stat_Size (Fd : Integer) return Integer with
      Import,
      Convention    => C,
      External_Name => "gneiss_fstat_size",
      Global        => (Input => Linux);

   procedure Mmap (Fd       :     Integer;
                   Addr     : out System.Address;
                   Writable :     Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_mmap",
      Global        => (In_Out => Linux);

   procedure Munmap (Fd   :        Integer;
                     Addr : in out System.Address) with
      Import,
      Convention    => C,
      External_Name => "gneiss_munmap",
      Global        => (In_Out => Linux);

end Gneiss_Syscall;
