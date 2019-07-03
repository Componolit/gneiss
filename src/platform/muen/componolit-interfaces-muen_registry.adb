package body Componolit.Interfaces.Muen_Registry with
   SPARK_Mode
is

   procedure Call_Block_Event (S : Session_Entry)
   is
      procedure Event with
         Import,
         Address => S.Block_Event;
   begin
      Event;
   end Call_Block_Event;

   procedure Call_Timer_Event (S : Session_Entry;
                               I : CIM.Session_Index)
   is
      procedure Event (Index : CIM.Session_Index) with
         Import,
         Address => S.Timeout_Event;
   begin
      Event (I);
   end Call_Timer_Event;

end Componolit.Interfaces.Muen_Registry;
