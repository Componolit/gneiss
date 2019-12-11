
with Gneiss_Internal.Block;

package body Gneiss.Muen_Registry with
   SPARK_Mode
is

   procedure Call_Block_Client_Event (S : Session_Entry)
   is
      procedure Event with
         Import,
         Address => S.Block_Client_Event;
   begin
      Event;
   end Call_Block_Client_Event;

   procedure Call_Block_Dispatcher_Event (S : Session_Entry)
   is
      Session : Gneiss_Internal.Block.Dispatcher_Session with
         Import,
         Address => S.Session;
      procedure Event (D : Gneiss_Internal.Block.Dispatcher_Session) with
         Import,
         Address => S.Block_Dispatch_Event;
   begin
      Event (Session);
   end Call_Block_Dispatcher_Event;

   procedure Call_Block_Server_Event (S : Session_Entry)
   is
      procedure Event with
         Import,
         Address => S.Block_Server_Event;
   begin
      Event;
   end Call_Block_Server_Event;

   procedure Call_Timer_Event (S : Session_Entry;
                               I : CIM.Session_Id)
   is
      procedure Event (Index : CIM.Session_Id) with
         Import,
         Address => S.Timeout_Event;
   begin
      Event (I);
   end Call_Timer_Event;

end Gneiss.Muen_Registry;
