
with System;
with Cxx;
with Cxx.Block;
with Cxx.Block.Client;
with Cxx.Genode;

package body Gneiss.Block with
   SPARK_Mode
is
   use type Cxx.Bool;
   use type System.Address;

   ------------
   -- Client --
   ------------

   function Initialized (C : Client_Session) return Boolean is
      (C.Instance.Device /= System.Null_Address
       and then C.Instance.Callback /= System.Null_Address
       and then C.Instance.Write /= System.Null_Address
       and then C.Instance.Env /= System.Null_Address);

   function Identifier (C : Client_Session) return Session_Id is
      (Session_Id'Val (C.Instance.Tag));

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

   function Identifier (D : Dispatcher_Session) return Session_Id is
      (Session_Id'Val (D.Instance.Tag));

   ------------
   -- Server --
   ------------

   function Initialized (S : Server_Session) return Boolean is
      (S.Instance.Session /= System.Null_Address
       and then S.Instance.Callback /= System.Null_Address
       and then S.Instance.Block_Count /= System.Null_Address
       and then S.Instance.Block_Size /= System.Null_Address
       and then S.Instance.Writable /= System.Null_Address);

   function Valid (S : Server_Session) return Boolean is
      (Cxx.Genode.Uint32_T'Pos (S.Instance.Tag) + Session_Id'Pos (Session_Id'First) in
             Session_Id'Pos (Session_Id'First) .. Session_Id'Pos (Session_Id'Last));

   function Identifier (S : Server_Session) return Session_Id is
      (Session_Id'Val (Cxx.Genode.Uint32_T'Pos (S.Instance.Tag) + Session_Id'Pos (Session_Id'First)));

end Gneiss.Block;
