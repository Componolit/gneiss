
with System;
with C;

package body Componolit.Interfaces.Block with
   SPARK_Mode
is
   use type System.Address;
   use type C.Uint32_T;
   use type C.Uint64_T;
   use type Componolit.Interfaces.Internal.Block.Request_Status;

   ------------
   -- Client --
   ------------

   function Kind (R : Client_Request) return Request_Kind is
      (case R.Kind is
          when Componolit.Interfaces.Internal.Block.Read  => Read,
          when Componolit.Interfaces.Internal.Block.Write => Write,
          when Componolit.Interfaces.Internal.Block.Sync  => Sync,
          when Componolit.Interfaces.Internal.Block.Trim  => Trim,
          when others                                     => None);

   function Status (R : Client_Request) return Request_Status is
      (if
          R.Status = Componolit.Interfaces.Internal.Block.Raw
       then
          Raw
       else
          (if
              R.Length <= C.Uint64_T (Count'Last)
              and then Request_Id'Pos (Request_Id'First) <= R.Tag
              and then Request_Id'Pos (Request_Id'Last) >= R.Tag
           then
              (case R.Status is
                  when Componolit.Interfaces.Internal.Block.Allocated => Allocated,
                  when Componolit.Interfaces.Internal.Block.Pending   => Pending,
                  when Componolit.Interfaces.Internal.Block.Ok        => Ok,
                  when Componolit.Interfaces.Internal.Block.Error     => Error,
                  when others                                         => Raw)
           else
              Error));

   function Start (R : Client_Request) return Id is
      (Id (R.Start));

   function Length (R : Client_Request) return Count is
      (Count (R.Length));

   function Identifier (R : Client_Request) return Request_Id is
      (Request_Id'Val (R.Tag));

   function Initialized (C : Client_Session) return Boolean is
      (C.Event /= System.Null_Address
       and then C.Rw /= System.Null_Address
       and then C.Fd > -1);

   function Assigned (C : Client_Session; R : Client_Request) return Boolean is
      (R.Session = C.Tag);

   function Identifier (C : Client_Session) return Session_Id is
      (Session_Id'Val (Standard.C.Uint32_T'Pos (C.Tag) + Session_Id'Pos (Session_Id'First)));

   function C_Writable (T : Client_Session) return Integer with
      Import,
      Convention    => C,
      External_Name => "block_client_writable",
      Global        => null;

   function Writable (C : Client_Session) return Boolean is
      (C_Writable (C) = 1);

   function C_Block_Count (T : Client_Session) return Count with
      Import,
      Convention    => C,
      External_Name => "block_client_block_count",
      Global        => null;

   function Block_Count (C : Client_Session) return Count is
      (C_Block_Count (C));

   function C_Block_Size (T : Client_Session) return Size with
      Import,
      Convention    => C,
      External_Name => "block_client_block_size",
      Global        => null;

   function Block_Size (C : Client_Session) return Size is
      (C_Block_Size (C));

   ----------------
   -- Dispatcher --
   ----------------

   function Initialized (D : Dispatcher_Session) return Boolean is
      (False);

   function Identifier (D : Dispatcher_Session) return Session_Id is
      (Session_Id'First);

   ------------
   -- Server --
   ------------

   function Kind (R : Server_Request) return Request_Kind is
      (None);

   function Status (R : Server_Request) return Request_Status is
      (Raw);

   function Start (R : Server_Request) return Id is
      (0);

   function Length (R : Server_Request) return Count is
      (0);

   function Initialized (S : Server_Session) return Boolean is
      (False);

   function Valid (S : Server_Session) return Boolean is
      (False);

   function Assigned (S : Server_Session;
                      R : Server_Request) return Boolean is
      (False);

   function Identifier (S : Server_Session) return Session_Id is
      (Session_Id'First);

end Componolit.Interfaces.Block;
