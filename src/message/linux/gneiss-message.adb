
with Gneiss.Platform;

package body Gneiss.Message with
   SPARK_Mode
is

   function Initialized (C : Client_Session) return Boolean is
      (False);

   function Initialized (R : Server_Session) return Boolean is
      (False);

   function Initialized (D : Dispatcher_Session) return Boolean is
      (False);

end Gneiss.Message;
