
with Musinfo;
with Interfaces;
with Muchannel;
with Muchannel_Constants;
private with Muchannel.Readers;

generic
   type Element_Type is private;
   Elements     : Positive;
   Null_Element : Element_Type;
   Protocol     : Standard.Interfaces.Unsigned_64;
package Componolit.Interfaces.Muchannel_Reader with
   SPARK_Mode
is
   use type Musinfo.Memregion_Type;

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

   type Reader_Type is private;
   Null_Reader : constant Reader_Type;

   procedure Pending (Mem    :     Musinfo.Memregion_Type;
                      Reader :     Reader_Type;
                      Result : out Boolean) with
      Pre => Mem /= Musinfo.Null_Memregion;

   procedure Read (Mem     :        Musinfo.Memregion_Type;
                   Reader  : in out Reader_Type;
                   Element :    out Element_Type;
                   Result  :    out Result_Type) with
      Pre => Mem /= Musinfo.Null_Memregion;

   procedure Drain (Mem    :        Musinfo.Memregion_Type;
                    Reader : in out Reader_Type) with
      Pre => Mem /= Musinfo.Null_Memregion;

   function Peek (Mem    : Musinfo.Memregion_Type;
                  Reader : Reader_Type;
                  Skip   : Standard.Interfaces.Unsigned_64 := 0) return Element_Type with
      Pre => Mem /= Musinfo.Null_Memregion;

private

   type Dummy_Header_Type is record
      Transport : Channel.Header_Field_Type;
      Epoch     : Channel.Header_Field_Type;
      Protocol  : Channel.Header_Field_Type;
      Size      : Channel.Header_Field_Type;
      Elements  : Channel.Header_Field_Type;
      Reserved  : Channel.Header_Field_Type;
      WSC       : Channel.Header_Field_Type;
      WC        : Channel.Header_Field_Type;
   end record with
      Size => 8 * Muchannel_Constants.Header_Size;

   type Peek_Data_Range is new Natural range 0 .. Elements - 1;
   type Peek_Data_Type is array (Peek_Data_Range) of Element_Type;

   type Peek_Channel_Type is record
      Header : Dummy_Header_Type;
      Data   : Peek_Data_Type;
   end record with
      Pack;

   type Peek_Reader_Type is record
      Epoch    : Channel.Header_Field_Type;
      Protocol : Channel.Header_Field_Type;
      Size     : Channel.Header_Field_Type;
      Elements : Channel.Header_Field_Type;
      RC       : Channel.Header_Field_Type;
   end record;

   function Peek (Chn : Peek_Channel_Type;
                  Rdr : Peek_Reader_Type;
                  Skp : Channel.Header_Field_Type) return Element_Type;

   package Mureader is new Channel.Readers;
   type Reader_Type is new Mureader.Reader_Type;
   Null_Reader : constant Reader_Type := Reader_Type (Mureader.Null_Reader);

end Componolit.Interfaces.Muchannel_Reader;
