
with System;
with Gneiss_Internal;
with Gneiss_Internal.Syscall;

package body Gneiss.Config with
   SPARK_Mode
is

   procedure Load (Location : String)
   is
      use type System.Address;
      Fd   : Gneiss_Internal.File_Descriptor;
      Addr : System.Address;
   begin
      Gneiss_Internal.Syscall.Open (Location & ASCII.NUL, Fd, False);
      if not Gneiss_Internal.Valid (Fd) then
         return;
      end if;
      Gneiss_Internal.Syscall.Mmap (Fd, Addr, False);
      if Addr = System.Null_Address then
         Gneiss_Internal.Syscall.Close (Fd);
         return;
      end if;
      declare
         Size : constant Integer := Gneiss_Internal.Syscall.Stat_Size (Fd);
         Data : String (1 .. Size) with
            Import,
            Address => Addr;
      begin
         Parse (Data);
      end;
      Gneiss_Internal.Syscall.Munmap (Fd, Addr);
      Gneiss_Internal.Syscall.Close (Fd);
   end Load;

end Gneiss.Config;
