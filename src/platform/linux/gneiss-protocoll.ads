
with RFLX.Session;

generic
   type Byte is (<>);
   type Buffer is array (RFLX.Session.Length_Type range <>) of Byte;
package Gneiss.Protocoll with
   SPARK_Mode
is

   pragma Compile_Time_Error (Byte'Size /= 8, "Byte must bit 8 bit long");

   type Message (Length : RFLX.Session.Length_Type) is record
      Action         : RFLX.Session.Action_Type;
      Kind           : RFLX.Session.Kind_Type;
      Name_Length    : RFLX.Session.Length_Type;
      Payload : Buffer (1 .. Length);
   end record;

   for Message use record
      Action      at 0 range 0 .. 7;
      Kind        at 0 range 8 .. 15;
      Name_Length at 0 range 16 .. 23;
      Length      at 0 range 24 .. 31;
   end record;

   procedure Send_Message (Destination : Integer;
                           Data        : Message;
                           File_Desc   : Integer := -1);

end Gneiss.Protocoll;