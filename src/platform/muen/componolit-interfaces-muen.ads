
with Musinfo;

package Componolit.Interfaces.Muen with
   SPARK_Mode
is

   type Status is (Running, Success, Failure);

   type Async_Session_Type is (None, Block);
   type Session_Index is new Natural range 0 .. 64;
   Invalid_Index : constant Session_Index := 0;

   function Name_To_String (Name : Musinfo.Name_Type) return String;

   function String_To_Name (Name : String) return Musinfo.Name_Type;

   Component_Status : Status := Running;

end Componolit.Interfaces.Muen;
