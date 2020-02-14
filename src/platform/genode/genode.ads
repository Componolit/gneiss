
package Genode with
   SPARK_Mode
is

   subtype Session_Label is String (1 .. 160);

   function To_String (S : Session_Label) return String;

end Genode;
