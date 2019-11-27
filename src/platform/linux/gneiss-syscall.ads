
with System;

package Gneiss.Syscall with
   SPARK_Mode
is

   procedure Socketpair (Fd1 : out Integer;
                         Fd2 : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_socketpair";

   procedure Fork (Pid : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_fork";

   procedure Close (Fd : in out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_close";

   procedure Waitpid (Pid : Integer;
                      Status : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_waitpid";

   procedure Dup (Oldfd :     Integer;
                  Newfd : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_dup";

   procedure Write_Message (Socket  : Integer;
                            Message : System.Address;
                            Size    : Integer;
                            Fd      : Integer := -1) with
      Import,
      Convention => C,
      External_Name => "gneiss_write_message";

   procedure Peek_Message (Socket  :     Integer;
                           Message :     System.Address;
                           Size    :     Integer;
                           Fd      : out Integer;
                           Trunc   : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_peek_message";

   procedure Drop_Message (Socket : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_drop_message";

end Gneiss.Syscall;
