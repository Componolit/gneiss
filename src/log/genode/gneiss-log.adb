
with System;

package body Gneiss.Log with
   SPARK_Mode
is
   use type System.Address;

   function Initialized (Session : Client_Session) return Boolean is
      (Session.Session /= System.Null_Address
       and then Session.Cursor in Session.Buffer'Range);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Session.Root /= System.Null_Address
       and then Session.Env /= System.Null_Address
       and then Session.Dispatch /= System.Null_Address);

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Component /= System.Null_Address
       and then Session.Write /= System.Null_Address);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Log;
