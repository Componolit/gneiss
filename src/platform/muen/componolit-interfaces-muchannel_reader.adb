
with Ada.Unchecked_Conversion;
with System;

package body Componolit.Interfaces.Muchannel_Reader with
   SPARK_Mode
is

   procedure Pending (Mem    :     Musinfo.Memregion_Type;
                      Reader :     Reader_Type;
                      Result : out Boolean) with
      SPARK_Mode => Off
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Writers;
   begin
      Mureader.Has_Pending_Data (Chn, Mureader.Reader_Type (Reader), Result);
   end Pending;

   procedure Read (Mem     :        Musinfo.Memregion_Type;
                   Reader  : in out Reader_Type;
                   Element :    out Element_Type;
                   Result  :    out Result_Type) with
      SPARK_Mode => Off
   is
      use type Mureader.Result_Type;
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Writers;
      Res : Mureader.Result_Type;
   begin
      Mureader.Read (Chn, Mureader.Reader_Type (Reader), Element, Res);
      Result := (case Res is
                    when Mureader.Inactive               => Inactive,
                    when Mureader.Incompatible_Interface => Incompatible_Interface,
                    when Mureader.Epoch_Changed          => Epoch_Changed,
                    when Mureader.No_Data                => No_Data,
                    when Mureader.Overrun_Detected       => Overrun_Detected,
                    when Mureader.Success                => Success);
   end Read;

   procedure Drain (Mem    :        Musinfo.Memregion_Type;
                    Reader : in out Reader_Type) with
      SPARK_Mode => Off
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Writers;
   begin
      Mureader.Drain (Chn, Mureader.Reader_Type (Reader));
   end Drain;

   function Peek (Mem    : Musinfo.Memregion_Type;
                  Reader : Reader_Type;
                  Skip   : Standard.Interfaces.Unsigned_64 := 0) return Element_Type with
      Spark_Mode => Off
   is
      Chn : Peek_Channel_Type with
         Address => System'To_Address (Mem.Address);
      function Convert_Reader is new Ada.Unchecked_Conversion (Reader_Type, Peek_Reader_Type);
      Rdr : constant Peek_Reader_Type := Convert_Reader (Reader);
   begin
      return Peek (Chn, Rdr, Channel.Header_Field_Type (Skip));
   end Peek;

   function Peek (Chn : Peek_Channel_Type;
                  Rdr : Peek_Reader_Type;
                  Skp : Channel.Header_Field_Type) return Element_Type
   is
      use type Channel.Header_Field_Type;
      Position : constant Peek_Data_Range :=
         Peek_Data_Range ((Rdr.RC + Skp) mod Channel.Header_Field_Type (Elements));
   begin
      if
         Chn.Header.Epoch          /= Channel.Header_Field_Type'First
         and then Chn.Header.Epoch  = Rdr.Epoch
         and then Rdr.Protocol      = Channel.Header_Field_Type (Protocol)
         and then Rdr.Size          = Chn.Header.Size
         and then Rdr.Elements      = Chn.Header.Elements
         and then Rdr.RC + Skp      < Chn.Header.WC
      then
         return Chn.Data (Position);
      else
         return Null_Element;
      end if;
   end Peek;

end Componolit.Interfaces.Muchannel_Reader;
