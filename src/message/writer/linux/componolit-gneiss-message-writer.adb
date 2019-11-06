
with System;
with Componolit.Gneiss.Platform;

package body Componolit.Gneiss.Message.Writer with
   SPARK_Mode
is

   package Gns renames Componolit.Gneiss;

   procedure Initialize (W : in out Writer_Session;
                         C :        Componolit.Gneiss.Types.Capability;
                         L :        String)
   is
   begin
      Gns.Platform.Find_Resource (C, "Message", L, 2, System.Null_Address, W.Resource);
   end Initialize;

   procedure Write (W : in out Writer_Session;
                    B :        Message_Buffer)
   is
      procedure Mq_Write (R   : in out Gns.Platform.Resource_Descriptor;
                          Buf :        System.Address;
                          Siz :        Long_Integer) with
         Import,
         Convention => C,
         External_Name => "message_writer_write";
   begin
      Mq_Write (W.Resource, B'Address, B'Length);
   end Write;

   procedure Finalize (W : in out Writer_Session)
   is
   begin
      W.Resource.Fd := -1;
      --  FIXME: Set event to 0
   end Finalize;

end Componolit.Gneiss.Message.Writer;
