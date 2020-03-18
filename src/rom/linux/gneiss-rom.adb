
with System;

package body Gneiss.Rom with
   SPARK_Mode
is
   use type System.Address;

   function Initialized (Session : Client_Session) return Boolean is
      (Session.Index.Valid
       and then Session.Fd > -1
       and then Session.Map /= System.Null_Address);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Rom;
