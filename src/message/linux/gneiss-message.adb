
package body Gneiss.Message with
   SPARK_Mode
is

   function Status (Session : Client_Session) return Session_Status is
      (if Session.Broker >= 0 then Pending else
         (if Session.File_Descriptor < 0 then Uninitialized else Initialized));

   function Status (Session : Server_Session) return Session_Status is
      (Uninitialized);

   function Status (Session : Dispatcher_Session) return Session_Status is
      (Uninitialized);

end Gneiss.Message;
