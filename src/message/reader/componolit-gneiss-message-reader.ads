
with Componolit.Gneiss.Types;

generic
   type Element is mod <>;
   type Index is range <>;
   type Buffer is array (Index range <>) of Element;
   Size : Index;
   with procedure Event;
package Componolit.Gneiss.Message.Reader with
   SPARK_Mode
is

   pragma Compile_Time_Error (not (Element'Size mod 8 = 0),
                              "Only byte granular mod types are allowed");

   subtype Message_Buffer is Buffer (Index'First .. Index'First + (Size - 1));

   procedure Initialize (R : in out Reader_Session;
                         C :        Componolit.Gneiss.Types.Capability;
                         L :        String);

   function Available (R : Reader_Session) return Boolean;

   procedure Read (R : in out Reader_Session;
                   B :    out Message_Buffer);

   procedure Finalize (R : in out Reader_Session);

end Componolit.Gneiss.Message.Reader;
