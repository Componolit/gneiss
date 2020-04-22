
with Gneiss_Internal.Linux;

package body Gneiss_Internal.Linker with
   SPARK_Mode => Off
is

   procedure Open (File   :     String;
                   Handle : out Dl_Handle)
   is
      C_File : String := File & ASCII.NUL;
   begin
      Linux.Dl_Open (C_File'Address, Handle);
   end Open;

   function Symbol (Handle : Dl_Handle;
                    Name   : String) return System.Address
   is
      C_Name : String := Name & ASCII.NUL;
   begin
      return Linux.Dl_Sym (Handle, C_Name'Address);
   end Symbol;

end Gneiss_Internal.Linker;
