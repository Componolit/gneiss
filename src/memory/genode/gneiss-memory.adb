
with System;

package body Gneiss.Memory with
   SPARK_Mode
is
   use type System.Address;

   function Status (Session : Client_Session) return Session_Status is
      (if Session.Index.Valid
          and then Session.Rom /= System.Null_Address
          and then Session.Event /= System.Null_Address
          and then Session.Modify /= System.Null_Address
       then Initialized else Uninitialized);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Index);

end Gneiss.Memory;
