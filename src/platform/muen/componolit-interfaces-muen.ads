
with Musinfo;
with Interfaces;

package Componolit.Interfaces.Muen with
   SPARK_Mode
is

   type Status is (Running, Success, Failure);

   type Async_Session_Type is (None, Block_Client);
   type Session_Index is new Natural range 0 .. 64;
   Invalid_Index : constant Session_Index := 0;

   function Name_To_String (Name : Musinfo.Name_Type) return String;

   function String_To_Name (Name : String) return Musinfo.Name_Type;

   function Str_Cut (S : String) return String;

   Component_Status : Status := Running;

   procedure Yield (Epoch : in out Standard.Interfaces.Unsigned_64);

end Componolit.Interfaces.Muen;
