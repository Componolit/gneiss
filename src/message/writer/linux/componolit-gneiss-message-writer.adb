
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
      use type Gns.Platform.Access_Mode;
      Res : Gns.Platform.Resource_Descriptor := Gns.Platform.Get_Resource_Descriptor (C);
   begin
      if Initialized (W) then
         return;
      end if;
      while Gns.Platform.Valid_Resource_Descriptor (Res) loop
         if
            Gns.Platform.Resource_Type (Res) = "Message"
            and then Gns.Platform.Resource_Label (Res) = L
            and then Gns.Platform.Resource_Mode (Res) = Gns.Platform.Write
         then
            W.Resource := Res;
            return;
         end if;
         Res := Gns.Platform.Next_Resource_Descriptor (Res);
      end loop;
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
      if not Initialized (W) then
         return;
      end if;
      W.Resource := Gns.Platform.Invalid_Resource;
   end Finalize;

end Componolit.Gneiss.Message.Writer;
