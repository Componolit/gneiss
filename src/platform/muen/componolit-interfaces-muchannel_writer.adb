
with System;

package body Componolit.Interfaces.Muchannel_Writer with
   SPARK_Mode
is

   procedure Activate (Mem   : Musinfo.Memregion_Type;
                       Epoch : Channel.Header_Field_Type := 1) with
      SPARK_Mode => Off
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Muwriter.Initialize (Chn, Epoch);
   end Activate;

   procedure Deactivate (Mem : Musinfo.Memregion_Type) with
      SPARK_Mode => Off
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Muwriter.Deactivate (Chn);
   end Deactivate;

   procedure Write (Mem : Musinfo.Memregion_Type;
                    Elm : Element_Type) with
      SPARK_Mode => Off
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Muwriter.Write (Chn, Elm);
   end Write;

   procedure Is_Active (Mem    :     Musinfo.Memregion_Type;
                        Result : out Boolean) with
      SPARK_Mode => Off
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address);
   begin
      Channel.Is_Active (Chn, Result);
   end Is_Active;

end Componolit.Interfaces.Muchannel_Writer;
