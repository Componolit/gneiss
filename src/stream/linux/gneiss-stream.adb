
package body Gneiss.Stream with
   SPARK_Mode
is

   function Initialized (Session : Client_Session) return Boolean is
      (False);

   function Initialized (Session : Server_Session) return Boolean is
      (False);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (False);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session_Index_Option'(Valid => False));

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session_Index_Option'(Valid => False));

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session_Index_Option'(Valid => False));

   function Registered (Session : Dispatcher_Session) return Boolean is
      (False);

end Gneiss.Stream;
