package body Componolit.Interfaces.Muen_Registry with
   SPARK_Mode
is

   procedure Call_Block_Event (S : Session_Entry) with
      SPARK_Mode => Off
   is
      procedure Event with
         Import,
         Address => S.Block_Event;
   begin
      Event;
   end Call_Block_Event;

end Componolit.Interfaces.Muen_Registry;
