
with System;
with Componolit.Gneiss.Platform;

package body Componolit.Gneiss.Message.Reader with
   SPARK_Mode
is
   package Gns renames Componolit.Gneiss;

   function Event_Address return System.Address;

   function Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event'Address;
   end Event_Address;

   procedure Initialize (R : in out Reader_Session;
                         C :        Componolit.Gneiss.Types.Capability;
                         L :        String)
   is
   begin
      Gns.Platform.Find_Resource (C, "Message", L, 1, Event_Address, R.Resource);
   end Initialize;

   function Available (R : Reader_Session) return Boolean
   is
      function Mq_Avail (Res : Gns.Platform.Resource_Descriptor) return Integer with
         Import,
         Convention => C,
         External_Name => "message_reader_available";
   begin
      return Mq_Avail (R.Resource) = 1;
   end Available;

   procedure Read (R : in out Reader_Session;
                   B :    out Message_Buffer)
   is
      procedure Mq_Read (Res : in out Gns.Platform.Resource_Descriptor;
                         Buf :    out Message_Buffer;
                         Siz :        Long_Integer) with
         Import,
         Convention => C,
         External_Name => "message_reader_read";
   begin
      Mq_Read (R.Resource, B, B'Length);
   end Read;

   procedure Finalize (R : in out Reader_Session)
   is
   begin
      R.Resource.Fd := -1;
      --  FIXME: Set event to 0
   end Finalize;

end Componolit.Gneiss.Message.Reader;
