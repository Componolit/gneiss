package body Componolit.Interfaces.Muen_Registry with
   SPARK_Mode
is

   procedure Call_Block_Client_Event (S : Session_Entry) with
      SPARK_Mode => Off
   is
      procedure Event with
         Import,
         Address => S.Block_Client_Event;
   begin
      Event;
   end Call_Block_Client_Event;

   procedure Call_Block_Dispatcher_Event (S : Session_Entry) with
      SPARK_Mode => Off
   is
      use type System.Address;
   begin
      if S.Block_Dispatch_Event /= System.Null_Address then
         declare
            procedure Event with
               Import,
               Address => S.Block_Dispatch_Event;
         begin
            Event;
         end;
      end if;
   end Call_Block_Dispatcher_Event;

end Componolit.Interfaces.Muen_Registry;
