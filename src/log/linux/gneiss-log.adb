
with Gneiss_Platform;

package body Gneiss.Log with
   SPARK_Mode
is

   function Status (Session : Client_Session) return Session_Status is
      (if Session.Pending then Pending else
         (if Session.File_Descriptor < 0 then Uninitialized else Initialized));

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Gneiss_Platform.Is_Valid (Session.Register_Service));

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Fd >= 0 and then Gneiss_Platform.Is_Valid (Session.E_Cap));

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Log;
