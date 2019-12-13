
with System;

package Gneiss.Syscall with
   SPARK_Mode,
   Abstract_State => Linux,
   Initializes    => Linux,
   Elaborate_Body
is

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
                            Fd      : Integer := -1) with
      Import,
      Convention => C,
      External_Name => "gneiss_write_message",
      Global        => (In_Out => Linux);

   procedure Peek_Message (Socket  :     Integer;
                           Message :     System.Address;
                           Size    :     Integer;
                           Fd      : out Integer;
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
      Global        => (In_Out => Linux);

   function Get_Pid return Integer with
      Import,
      Convention    => C,
      External_Name => "getpid",
      Global        => (Input => Linux);

end Gneiss.Syscall;
