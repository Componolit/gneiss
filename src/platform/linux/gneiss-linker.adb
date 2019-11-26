
package body Gneiss.Linker with
   SPARK_Mode
is

   procedure Open (File   :     String;
                   Handle : out Dl_Handle) with
      SPARK_Mode => Off
   is
      procedure Dl_Open (F :     System.Address;
                         H : out Dl_Handle) with
         Import,
         Convention => C,
         External_Name => "gneiss_dlopen";
      C_File : String := File & ASCII.NUL;
   begin
      Dl_Open (C_File'Address, Handle);
   end Open;

   function Symbol (Handle : Dl_Handle;
                    Name   : String) return System.Address with
      SPARK_Mode => Off
   is
      function Dl_Sym (H : Dl_Handle;
                       N : System.Address) return System.Address with
         Import,
         Convention => C,
         External_Name => "gneiss_dlsym";
      C_Name : String := Name & ASCII.NUL;
   begin
      return Dl_Sym (Handle, C_Name'Address);
   end Symbol;

end Gneiss.Linker;
