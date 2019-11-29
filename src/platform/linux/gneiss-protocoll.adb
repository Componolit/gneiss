
with Gneiss.Syscall;

package body Gneiss.Protocoll with
   SPARK_Mode
is

   procedure Send_Message (Destination : Integer;
                           Data        : Message;
                           File_Desc   : Integer := -1) with
      SPARK_Mode => Off
   is
   begin
      Gneiss.Syscall.Write_Message (Destination, Data'Address, Data'Size / 8, File_Desc);
   end Send_Message;

end Gneiss.Protocoll;
