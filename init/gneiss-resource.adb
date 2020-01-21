
package body Gneiss.Resource with
   SPARK_Mode
is

   procedure Allocate_Fd (Kind :     RFLX.Session.Kind_Type;
                          Fds  : out Gneiss_Syscall.Fd_Array)
   is
   begin
      Fds := (others => -1);
      case Kind is
         when RFLX.Session.Message | RFLX.Session.Log =>
            Gneiss_Syscall.Socketpair (Fds (Fds'First), Fds (Fds'First + 1));
      end case;
   end Allocate_Fd;

   function Truncate (Kind : RFLX.Session.Kind_Type;
                      Fds  : Gneiss_Syscall.Fd_Array) return Gneiss_Syscall.Fd_Array
   is
   begin
      case Kind is
         when RFLX.Session.Message | RFLX.Session.Log =>
            return Fds (Fds'First .. Fds'First + 1);
      end case;
   end Truncate;

end Gneiss.Resource;
