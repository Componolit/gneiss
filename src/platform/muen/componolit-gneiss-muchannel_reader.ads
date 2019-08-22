
with Musinfo;
with Interfaces;
with Muchannel;
private with Muchannel.Readers;

generic
   type Element_Type is private;
   Elements     : Positive;
   Null_Element : Element_Type;
   Protocol     : Standard.Interfaces.Unsigned_64;
   Channel_Size : Standard.Interfaces.Unsigned_64;
package Componolit.Gneiss.Muchannel_Reader with
   SPARK_Mode
is
   use type Musinfo.Memregion_Type;
   use type Standard.Interfaces.Unsigned_64;

   type Result_Type is (Inactive,
                        Incompatible_Interface,
                        Epoch_Changed,
                        No_Data,
                        Overrun_Detected,
                        Success);

   package Channel is new Muchannel (Element_Type,
                                     Elements,
                                     Null_Element,
                                     Protocol);

   pragma Compile_Time_Error (Channel.Channel_Type'Size <= Channel_Size,
                              "Channel_Type must be smaller or equal to channel size");

   type Reader_Type is private;
   Null_Reader : constant Reader_Type;

   procedure Pending (Mem    :     Musinfo.Memregion_Type;
                      Reader :     Reader_Type;
                      Result : out Boolean) with
      Pre => Mem /= Musinfo.Null_Memregion
             and then Mem.Size = Channel_Size;

   procedure Read (Mem     :        Musinfo.Memregion_Type;
                   Reader  : in out Reader_Type;
                   Element :    out Element_Type;
                   Result  :    out Result_Type) with
      Pre => Mem /= Musinfo.Null_Memregion
             and then Mem.Size = Channel_Size;

   procedure Drain (Mem    :        Musinfo.Memregion_Type;
                    Reader : in out Reader_Type) with
      Pre => Mem /= Musinfo.Null_Memregion
             and then Mem.Size = Channel_Size;

   procedure Is_Active (Mem    :     Musinfo.Memregion_Type;
                        Result : out Boolean) with
      Pre => Mem /= Musinfo.Null_Memregion;

private

   package Mureader is new Channel.Readers;
   type Reader_Type is new Mureader.Reader_Type;
   Null_Reader : constant Reader_Type := Reader_Type (Mureader.Null_Reader);

end Componolit.Gneiss.Muchannel_Reader;
