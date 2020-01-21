
package body Gneiss.Protocol with
   SPARK_Mode => Off
is

   procedure Send_Message (Destination : Integer;
                           Data        : Message;
                           File_Desc   : Gneiss_Syscall.Fd_Array := Gneiss_Syscall.Fd_Array'(1 .. 0 => -1))
   is
   begin
      Gneiss_Syscall.Write_Message (Destination, Data'Address, Data'Size / 8, File_Desc, File_Desc'Length);
   end Send_Message;

end Gneiss.Protocol;
