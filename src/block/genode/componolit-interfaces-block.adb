
with System;
with Cxx;
with Cxx.Block;
with Cxx.Block.Client;
with Cxx.Genode;

package body Componolit.Interfaces.Block with
   SPARK_Mode
is
   use type Cxx.Bool;
   use type Cxx.Genode.Uint32_T;
   use type System.Address;

   ------------
   -- Client --
   ------------

   function Kind (R : Client_Request) return Request_Kind is
      (case R.Packet.Opcode is
          when 0 => Read,
          when 1 => Write,
          when 2 => Sync,
          when 3 => Trim,
          when others => None);

   function Status (R : Client_Request) return Request_Status is
      (case R.Status is
          when Componolit.Interfaces.Internal.Block.Raw       => Raw,
          when Componolit.Interfaces.Internal.Block.Allocated => Allocated,
          when Componolit.Interfaces.Internal.Block.Pending   => Pending,
          when Componolit.Interfaces.Internal.Block.Ok        => Ok,
          when Componolit.Interfaces.Internal.Block.Error     => Error);

   function Start (R : Client_Request) return Id is
      (Id (R.Packet.Block_Number));

   function Length (R : Client_Request) return Count is
      (Count (R.Packet.Block_Count));

   function Identifier (R : Client_Request) return Request_Id is
      (Request_Id'Val (R.Packet.Tag));

   function Assigned (C : Client_Session;
                      R : Client_Request) return Boolean is
      (C.Instance.Tag = R.Session);

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

   function Kind (R : Server_Request) return Request_Kind is
      (case R.Request.Kind is
          when 1 => Read,
          when 2 => Write,
          when 3 => Sync,
          when 4 => Trim,
          when others => None);

   function Status (R : Server_Request) return Request_Status is
      (case R.Status is
          when Componolit.Interfaces.Internal.Block.Raw       => Raw,
          when Componolit.Interfaces.Internal.Block.Allocated => Allocated,
          when Componolit.Interfaces.Internal.Block.Pending   => Pending,
          when Componolit.Interfaces.Internal.Block.Ok        => Ok,
          when Componolit.Interfaces.Internal.Block.Error     => Error);

   function Start (R : Server_Request) return Id is
      (Id (R.Request.Block_Number));

   function Length (R : Server_Request) return Count is
      (Count (R.Request.Block_Count));

   function Assigned (S : Server_Session;
                      R : Server_Request) return Boolean is
      (S.Instance.Tag = R.Session);

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

end Componolit.Interfaces.Block;
