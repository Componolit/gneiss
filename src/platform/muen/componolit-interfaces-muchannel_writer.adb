
with System;

package body Componolit.Interfaces.Muchannel_Writer with
   SPARK_Mode => Off
is

   procedure Activate (Mem   : Musinfo.Memregion_Type;
                       Epoch : Channel.Header_Field_Type := 1)
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Muwriter.Initialize (Chn, Epoch);
   end Activate;

   procedure Deactivate (Mem : Musinfo.Memregion_Type)
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Muwriter.Deactivate (Chn);
   end Deactivate;

   procedure Write (Mem : Musinfo.Memregion_Type;
                    Elm : Element_Type)
   is
      Chn : Channel.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Muwriter.Write (Chn, Elm);
   end Write;

end Componolit.Interfaces.Muchannel_Writer;
