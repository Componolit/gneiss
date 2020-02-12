
with System;

package body Gneiss.Message with
   SPARK_Mode
is
   use type System.Address;

   function Status (Session : Client_Session) return Session_Status is
      (if
          Session.Connection /= System.Null_Address
          and then Session.Event /= System.Null_Address
          and then Session.Init /= System.Null_Address
          and then Session.Index.Valid
       then
          Initialized
       else
          Uninitialized);

   function Initialized (Session : Server_Session) return Boolean is
      (False);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (False);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session_Index_Option'(Valid => False));

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session_Index_Option'(Valid => False));

end Gneiss.Message;
