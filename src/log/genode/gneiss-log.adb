
with System;
with Cxx;
with Cxx.Log.Client;

package body Gneiss.Log with
   SPARK_Mode
is
   use type Cxx.Bool;
   use type System.Address;

   function Status (Session : Client_Session) return Session_Status is
      (if Cxx.Log.Client.Initialized (Session.Instance) = Cxx.Bool'Val (1)
          and then Session.Cursor in Session.Buffer'Range
       then Initialized
       else Uninitialized);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (False);

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Component /= System.Null_Address
       and then Session.Event /= System.Null_Address
       and then Session.Write /= System.Null_Address);

   function Index (Session : Client_Session) return Session_Index is
      (0);

   function Index (Session : Server_Session) return Session_Index is
      (0);

   function Index (Session : Dispatcher_Session) return Session_Index is
      (0);

end Gneiss.Log;
