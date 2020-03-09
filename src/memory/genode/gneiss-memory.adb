
with System;

package body Gneiss.Memory with
   SPARK_Mode
is
   use type System.Address;

   function Initialized (Session : Client_Session) return Boolean is
      (Session.Session /= System.Null_Address
       and then Session.Index.Valid);

   function Initialized (Session : Server_Session) return Boolean is
      (Session.Component /= System.Null_Address
       and then Session.Addr /= System.Null_Address
       and then Session.Index.Valid);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (Session.Root /= System.Null_Address
       and then Session.Env /= System.Null_Address
       and then Session.Dispatch /= System.Null_Address
       and then Session.Index.Valid);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Index);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Memory;
