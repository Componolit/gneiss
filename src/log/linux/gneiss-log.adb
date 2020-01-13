
with Gneiss_Platform;

package body Gneiss.Log with
   SPARK_Mode
is

   function Status (Session : Client_Session) return Session_Status is
      (Gneiss_Internal.Log.Message_Log.Status (Session.Message));

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Gneiss_Platform.Is_Valid (Session.Register_Service));

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Fd >= 0 and then Gneiss_Platform.Is_Valid (Session.E_Cap));

   function Index (Session : Client_Session) return Session_Index is
      (Gneiss_Internal.Log.Message_Log.Index (Session.Message));

   function Index (Session : Dispatcher_Session) return Session_Index is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index is
      (Session.Index);

end Gneiss.Log;
