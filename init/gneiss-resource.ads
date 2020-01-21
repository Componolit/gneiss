
with Gneiss_Syscall;
with RFLX.Session;

package Gneiss.Resource with
   SPARK_Mode
is

   procedure Allocate_Fd (Kind :     RFLX.Session.Kind_Type;
                          Fds  : out Gneiss_Syscall.Fd_Array) with
      Pre => Fds'Length >= 2;

   function Truncate (Kind : RFLX.Session.Kind_Type;
                      Fds  : Gneiss_Syscall.Fd_Array) return Gneiss_Syscall.Fd_Array;

end Gneiss.Resource;
