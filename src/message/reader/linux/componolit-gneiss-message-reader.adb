
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
      use type Gns.Platform.Access_Mode;
      Res     : Gns.Platform.Resource_Descriptor := Gns.Platform.Get_Resource_Descriptor (C);
      Success : Boolean;
   begin
      if
         Initialized (R)
         or else Gns.Platform.Valid_Resource_Descriptor (R.Resource)
      then
         return;
      end if;
      while Gns.Platform.Valid_Resource_Descriptor (Res) loop
         if
            Gns.Platform.Resource_Type (Res) = "Message"
            and then Gns.Platform.Resource_Label (Res) = L
            and then Gns.Platform.Resource_Mode (Res) = Gns.Platform.Read
         then
            Gns.Platform.Resource_Set_Event (Res, Event_Address, Success);
            if Success then
               R.Resource := Res;
            end if;
            return;
         end if;
         Res := Gns.Platform.Next_Resource_Descriptor (Res);
      end loop;
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
      Success : Boolean;
   begin
      if Initialized (R) then
         if Gns.Platform.Valid_Resource_Descriptor (R.Resource) then
            Gns.Platform.Resource_Delete_Event (R.Resource, Event_Address, Success);
         end if;
         R.Resource := Gns.Platform.Invalid_Resource;
      end if;
   end Finalize;

end Componolit.Gneiss.Message.Reader;
