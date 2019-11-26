
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

end Gneiss.Syscall;
