package body Componolit.Interfaces.Muen with
   SPARK_Mode
is

   function Name_To_String (Name : Musinfo.Name_Type) return String
   is
   begin
      return String (Name.Data (1 .. Positive (Name.Length)));
   end Name_To_String;

   function String_To_Name (Name : String) return Musinfo.Name_Type
   is
      Length : Positive;
      Muname : Musinfo.Name_Type;
   begin
      if Name'Length > Musinfo.Name_Index_Type'Last then
         Length := Musinfo.Name_Index_Type'Last;
      else
         Length := Name'Length;
      end if;
      Muname.Data (Muname.Data'First .. Muname.Data'First + Length - 1) :=
         Musinfo.Name_Data_Type (Name (Name'First .. Name'First + Length - 1));
      Muname.Length    := Musinfo.Name_Size_Type (Length);
      Muname.Padding   := 0;
      Muname.Null_Term := Character'First;
      return Muname;
   end String_To_Name;

   function Str_Cut (S : String) return String
   is
      Last : Positive := S'First;
   begin
      for I in S'Range loop
         exit when S (I) = Character'First;
         Last := I;
      end loop;
      return S (S'First .. Last);
   end Str_Cut;

end Componolit.Interfaces.Muen;
