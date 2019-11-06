
with Componolit.Gneiss.Types;

generic
   type Element is mod <>;
   type Index is range <>;
   type Buffer is array (Index range <>) of Element;
   Size : Index;
package Componolit.Gneiss.Message.Writer with
   SPARK_Mode
is
   pragma Compile_Time_Error (not (Element'Size mod 8 = 0),
                              "Only byte granular mod types are allowed");

   subtype Message_Buffer is Buffer (Index'First .. Index'First + (Size - 1));

   procedure Initialize (W : in out Writer_Session;
                         C :        Componolit.Gneiss.Types.Capability;
                         L :        String);

   procedure Write (W : in out Writer_Session;
                    B :        Message_Buffer);

   procedure Finalize (W : in out Writer_Session);

end Componolit.Gneiss.Message.Writer;
