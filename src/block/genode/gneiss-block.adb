
with System;
with Cxx;
with Cxx.Block;
with Cxx.Block.Client;

package body Gneiss.Block with
   SPARK_Mode
is
   use type Cxx.Bool;
   use type System.Address;

   ------------
   -- Client --
   ------------

   function Status (Session : Client_Session) return Session_Status is
      (if Session.Instance.Device /= System.Null_Address
          and then Session.Instance.Callback /= System.Null_Address
          and then Session.Instance.Write /= System.Null_Address
          and then Session.Instance.Env /= System.Null_Address
       then
          (if Session.Instance.Tag.Valid then Gneiss.Initialized else Gneiss.Pending)
       else
          Gneiss.Uninitialized);

   function Index (Session : Client_Session) return Session_Index_Option is
      (Session.Instance.Tag);

   function Writable (C : Client_Session) return Boolean is
      (Cxx.Block.Client.Writable (C.Instance) /= Cxx.Bool'Val (0));

   function Block_Count (C : Client_Session) return Count is
      (Count (Cxx.Block.Client.Block_Count (C.Instance)));

   function Block_Size (C : Client_Session) return Size is
      (Size (Cxx.Block.Client.Block_Size (C.Instance)));

   ----------------
   -- Dispatcher --
   ----------------

   function Initialized (D : Dispatcher_Session) return Boolean is
      (D.Instance.Root /= System.Null_Address
       and then D.Instance.Handler /= System.Null_Address);

   function Index (Session : Dispatcher_Session) return Session_Index_Option is
      (Session.Instance.Tag);

   ------------
   -- Server --
   ------------

   function Initialized (S : Server_Session) return Boolean is
      (S.Instance.Session /= System.Null_Address
       and then S.Instance.Callback /= System.Null_Address
       and then S.Instance.Block_Count /= System.Null_Address
       and then S.Instance.Block_Size /= System.Null_Address
       and then S.Instance.Writable /= System.Null_Address);

   function Index (Session : Server_Session) return Session_Index_Option is
      (Session.Instance.Tag);

end Gneiss.Block;
