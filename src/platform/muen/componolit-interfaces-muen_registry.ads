
with System;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;

package Componolit.Interfaces.Muen_Registry with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;
   package CIMB renames Componolit.Interfaces.Muen_Block;

   use type CIM.Async_Session_Type;

   type Session_Entry (Kind : CIM.Async_Session_Type := CIM.None) is record
      case Kind is
         when CIM.None =>
            null;
         when CIM.Block_Client =>
            Block_Client_Event   : System.Address;
         when CIM.Block_Dispatcher =>
            Block_Dispatch_Event : System.Address;
         when CIM.Block_Server =>
            Block_Server_Event   : System.Address;
      end case;
   end record;

   type Session_Registry is array (CIM.Session_Index range 1 .. CIM.Session_Index'Last) of Session_Entry;
   Registry : Session_Registry := (others => Session_Entry'(Kind => CIM.None));

   procedure Call_Block_Client_Event (S : Session_Entry) with
      Pre => S.Kind = CIM.Block_Client;

   procedure Call_Block_Dispatcher_Event (S : Session_Entry) with
      Pre => S.Kind = CIM.Block_Dispatcher;

   procedure Call_Block_Server_Event (S : Session_Entry) with
      Pre => S.Kind = CIM.Block_Server;

end Componolit.Interfaces.Muen_Registry;
