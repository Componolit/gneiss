
package body Gneiss.Log with
   SPARK_Mode
is

   function Status (Session : Client_Session) return Session_Status is
      (Gneiss_Internal.Log.Message_Log.Status (Session.Message));

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Gneiss_Internal.Log.Message_Log.Initialized (Session.Message));

   function Initialized (Session : Server_Session) return Boolean is
      (Gneiss_Internal.Log.Message_Log.Initialized (Session.Message));

   function Index (Session : Client_Session) return Session_Index is
      (Gneiss_Internal.Log.Message_Log.Index (Session.Message));

   function Index (Session : Dispatcher_Session) return Session_Index is
      (Gneiss_Internal.Log.Message_Log.Index (Session.Message));

   function Index (Session : Server_Session) return Session_Index is
      (Gneiss_Internal.Log.Message_Log.Index (Session.Message));

end Gneiss.Log;
