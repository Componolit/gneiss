
with Musinfo;

package Componolit.Interfaces.Muen with
   SPARK_Mode
is

   type Status is (Running, Success, Failure);

   function Name_To_String (Name : Musinfo.Name_Type) return String;

   function String_To_Name (Name : String) return Musinfo.Name_Type;

   Component_Status : Status := Running;

end Componolit.Interfaces.Muen;
