
with Interfaces;
with Muchannel;
with Musinfo;
private with Muchannel.Writer;

generic
   type Element_Type is private;
   Elements     : Positive;
   Null_Element : Element_Type;
   Protocol     : Standard.Interfaces.Unsigned_64;
   Channel_Size : Standard.Interfaces.Unsigned_64;
package Gneiss.Muchannel_Writer with
   SPARK_Mode
is
   use type Musinfo.Memregion_Type;
   use type Standard.Interfaces.Unsigned_64;

   package Channel is new Standard.Muchannel (Element_Type,
                                              Elements,
                                              Null_Element,
                                              Protocol);

   pragma Compile_Time_Error (Channel.Channel_Type'Size <= Channel_Size,
                              "Channel_Type must be smaller or equal to channel size");

   procedure Activate (Mem   : Musinfo.Memregion_Type;
                       Epoch : Channel.Header_Field_Type := 1) with
      Pre => Mem /= Musinfo.Null_Memregion
             and then Mem.Size = Channel_Size;

   procedure Deactivate (Mem : Musinfo.Memregion_Type) with
      Pre => Mem /= Musinfo.Null_Memregion
             and then Mem.Size = Channel_Size;

   procedure Write (Mem : Musinfo.Memregion_Type;
                    Elm : Element_Type) with
      Pre => Mem /= Musinfo.Null_Memregion
             and then Mem.Size = Channel_Size;

   procedure Is_Active (Mem    :     Musinfo.Memregion_Type;
                        Result : out Boolean) with
      Pre => Mem /= Musinfo.Null_Memregion;

private

   package Muwriter is new Channel.Writer;

end Gneiss.Muchannel_Writer;
