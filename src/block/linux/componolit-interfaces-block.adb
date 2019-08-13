
with System;

package body Componolit.Interfaces.Block with
   SPARK_Mode
is
   use type System.Address;

   ------------
   -- Client --
   ------------

   function Null_Request return Client_Request
   is
      (Client_Request'(Kind   => 0,
                       Tag    => 0,
                       Start  => 0,
                       Length => 0,
                       Status => 0,
                       Aiocb  => System.Null_Address));

   function Kind (R : Client_Request) return Request_Kind
   is
      (case R.Kind is
         when Componolit.Interfaces.Internal.Block.Read  => Read,
         when Componolit.Interfaces.Internal.Block.Write => Write,
         when Componolit.Interfaces.Internal.Block.Sync  => Sync,
         when Componolit.Interfaces.Internal.Block.Trim  => Trim,
         when others                                     => None);

   function Status (R : Client_Request) return Request_Status
   is
      (case R.Status is
         when Componolit.Interfaces.Internal.Block.Allocated => Allocated,
         when Componolit.Interfaces.Internal.Block.Pending   => Pending,
         when Componolit.Interfaces.Internal.Block.Ok        => Ok,
         when Componolit.Interfaces.Internal.Block.Error     => Error,
         when others                                         => Raw);

   function Start (R : Client_Request) return Id
   is
      (Id (R.Start));

   function Length (R : Client_Request) return Count
   is
      (Count (R.Length));

   function Identifier (R : Client_Request) return Request_Id
   is
      (Request_Id'Val (R.Tag));

   function Create return Client_Session is
   begin
      return Client_Session'(Instance => System.Null_Address);
   end Create;

   function Instance (C : Client_Session) return Client_Instance is
      function C_Get_Instance (T : System.Address) return Client_Instance with
         Import,
         Convention    => CPP,
         External_Name => "block_client_get_instance",
         Global        => null;
   begin
      return C_Get_Instance (C.Instance);
   end Instance;

   function Initialized (C : Client_Session) return Boolean is
      (C.Instance /= System.Null_Address);

   function Writable (C : Client_Session) return Boolean is
      function C_Writable (T : System.Address) return Integer with
         Import,
         Convention    => C,
         External_Name => "block_client_writable",
         Global        => null;
   begin
      return C_Writable (C.Instance) = 1;
   end Writable;

   function Block_Count (C : Client_Session) return Count is
      function C_Block_Count (T : System.Address) return Count with
         Import,
         Convention    => C,
         External_Name => "block_client_block_count",
         Global        => null;
   begin
      return C_Block_Count (C.Instance);
   end Block_Count;

   function Block_Size (C : Client_Session) return Size is
      function C_Block_Size (T : System.Address) return Size with
         Import,
         Convention    => C,
         External_Name => "block_client_block_size",
         Global        => null;
   begin
      return C_Block_Size (C.Instance);
   end Block_Size;

   ----------------
   -- Dispatcher --
   ----------------

   function Initialized (D : Dispatcher_Session) return Boolean is
      (False);

   function Create return Dispatcher_Session is
      (Dispatcher_Session'(Instance => System.Null_Address));

   function Instance (D : Dispatcher_Session) return Dispatcher_Instance is
      (Dispatcher_Instance (System.Null_Address));

   ------------
   -- Server --
   ------------

   function Null_Request return Server_Request is
      (null record);

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

   function Create return Server_Session is
      (Server_Session'(Instance => System.Null_Address));

   function Instance (S : Server_Session) return Server_Instance is
      (Server_Instance (System.Null_Address));

end Componolit.Interfaces.Block;
