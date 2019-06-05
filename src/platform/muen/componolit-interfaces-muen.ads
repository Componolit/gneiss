
package Componolit.Interfaces.Muen with
   SPARK_Mode
is

   type Session_Type is (None, Log);

   type Session_Element (Session : Session_Type := None) is record
      case Session is
         when None =>
            null;
         when Log =>
            null;
      end case;
   end record;

   type Session_Index is new Natural range 1 .. 256;

   type Session_List is array (Session_Index range <>) of Session_Element;

   procedure Main;

end Componolit.Interfaces.Muen;
