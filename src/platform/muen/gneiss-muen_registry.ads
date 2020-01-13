
with System;
with Interfaces;
with Gneiss.Muen;
with Gneiss.Muen_Block;

package Gneiss.Muen_Registry with
   SPARK_Mode
is
   package CIM renames Gneiss.Muen;
   package CIMB renames Gneiss.Muen_Block;

   use type CIM.Async_Session_Type;

   type Session_Entry (Kind : CIM.Async_Session_Type := CIM.None) is record
      case Kind is
         when CIM.None =>
            null;
         when CIM.Log_Client =>
            Log_Client_Event : System.Address;
         when CIM.Timer_Client =>
            Next_Timeout    : Standard.Interfaces.Unsigned_64;
            Timeout_Set     : Boolean;
            Timeout_Event   : System.Address;
         when CIM.Block_Client =>
            Block_Client_Event   : System.Address;
         when CIM.Block_Dispatcher =>
            Block_Dispatch_Event : System.Address;
            Tag                  : Standard.Interfaces.Unsigned_32;
            Session              : System.Address;
         when CIM.Block_Server =>
            Block_Server_Event   : System.Address;
      end case;
   end record;

   type Session_Registry is array (CIM.Session_Id range 1 .. CIM.Session_Id'Last) of Session_Entry;
   Registry : Session_Registry := (others => Session_Entry'(Kind => CIM.None));

   procedure Call_Block_Client_Event (S : Session_Entry) with
      Pre => S.Kind = CIM.Block_Client;

   procedure Call_Block_Dispatcher_Event (S : Session_Entry) with
      Pre => S.Kind = CIM.Block_Dispatcher;

   procedure Call_Block_Server_Event (S : Session_Entry) with
      Pre => S.Kind = CIM.Block_Server;

   procedure Call_Timer_Event (S : Session_Entry;
                               I : CIM.Session_Id) with
      Pre => S.Kind = CIM.Timer_Client;

   procedure Call_Log_Client_Event (S : Session_Entry) with
      Pre => S.Kind = CIM.Log_Client;

end Gneiss.Muen_Registry;
