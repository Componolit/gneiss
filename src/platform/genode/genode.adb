
package body Genode with
   SPARK_Mode
is

   function To_String (S : Session_Label) return String
   is
      Last : Natural := S'First - 1;
   begin
      for I in S'Range loop
         exit when S (I) = ASCII.NUL;
         Last := I;
      end loop;
      return S (S'First .. Last);
   end To_String;

end Genode;
