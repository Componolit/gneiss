
with System;

package body Gneiss.Memory with
   SPARK_Mode
is
   use type System.Address;

   function Status (Session : Client_Session) return Session_Status is
      (if Session.Index.Valid then
          (if Session.Fd >= 0 and then Session.Map /= System.Null_Address then Initialized else Pending)
       else
          Uninitialized);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Memory;
