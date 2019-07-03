
with System;

package body Componolit.Interfaces.Muchannel_Reader with
   SPARK_Mode
is

   procedure Pending (Mem    :     Musinfo.Memregion_Type;
                      Reader :     Reader_Type;
                      Result : out Boolean)
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
                   Result  :    out Result_Type)
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
                    Reader : in out Reader_Type)
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Writers;
   begin
      Mureader.Drain (Chn, Mureader.Reader_Type (Reader));
   end Drain;

end Componolit.Interfaces.Muchannel_Reader;
