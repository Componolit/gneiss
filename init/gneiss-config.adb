
with System;
with Gneiss_Syscall;

package body Gneiss.Config with
   SPARK_Mode
is

   procedure Load (Location : String)
   is
      use type System.Address;
      Fd   : Integer;
      Addr : System.Address;
   begin
      Gneiss_Syscall.Open (Location & ASCII.NUL, Fd, 0);
      if Fd < 0 then
         return;
      end if;
      Gneiss_Syscall.Mmap (Fd, Addr, 0);
      if Addr = System.Null_Address then
         Gneiss_Syscall.Close (Fd);
         return;
      end if;
      declare
         Size : constant Integer := Gneiss_Syscall.Stat_Size (Fd);
         Data : String (1 .. Size) with
            Import,
            Address => Addr;
      begin
         Parse (Data);
      end;
      Gneiss_Syscall.Munmap (Fd, Addr);
      Gneiss_Syscall.Close (Fd);
   end Load;

end Gneiss.Config;
