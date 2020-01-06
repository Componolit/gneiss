
with Gneiss.Syscall;

package body Gneiss.Protocol with
   SPARK_Mode => Off
is

   procedure Send_Message (Destination : Integer;
                           Data        : Message;
                           File_Desc   : Integer := -1)
   is
   begin
      Gneiss.Syscall.Write_Message (Destination, Data'Address, Data'Size / 8, File_Desc);
   end Send_Message;

end Gneiss.Protocol;
