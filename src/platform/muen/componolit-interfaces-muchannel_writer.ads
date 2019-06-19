
with Interfaces;
with Muchannel;
with Musinfo;
private with Muchannel.Writer;

generic
   type Element_Type is private;
   Elements     : Positive;
   Null_Element : Element_Type;
   Protocol     : Standard.Interfaces.Unsigned_64;
package Componolit.Interfaces.Muchannel_Writer with
   SPARK_Mode
is
   use type Musinfo.Memregion_Type;
   use type Standard.Interfaces.Unsigned_64;

   package Channel is new Standard.Muchannel (Element_Type,
                                              Elements,
                                              Null_Element,
                                              Protocol);

   procedure Activate (Mem   : Musinfo.Memregion_Type;
                       Epoch : Channel.Header_Field_Type := 1) with
      Pre => Mem /= Musinfo.Null_Memregion
             and then Mem.Size >= Channel.Channel_Type'Size;

   procedure Deactivate (Mem : Musinfo.Memregion_Type) with
      Pre => Mem /= Musinfo.Null_Memregion;

   procedure Write (Mem : Musinfo.Memregion_Type;
                    Elm : Element_Type) with
      Pre => Mem /= Musinfo.Null_Memregion;

private

   package Muwriter is new Channel.Writer;

end Componolit.Interfaces.Muchannel_Writer;
