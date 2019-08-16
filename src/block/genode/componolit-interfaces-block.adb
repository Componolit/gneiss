
with System;
with Cxx;
with Cxx.Block;
with Cxx.Block.Client;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;

package body Componolit.Interfaces.Block with
   SPARK_Mode
is
   use type Cxx.Bool;
   use type System.Address;

   ------------
   -- Client --
   ------------

   function Null_Request return Client_Request is
      (Client_Request'(Packet => Cxx.Block.Client.Packet_Descriptor'(Offset       => 0,
                                                                     Bytes        => 0,
                                                                     Opcode       => -1,
                                                                     Tag          => 0,
                                                                     Block_Number => 0,
                                                                     Block_Count  => 0),
                       Status => Componolit.Interfaces.Internal.Block.Raw));

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

   function Create return Client_Session is
      (Client_Session'(Instance => Cxx.Block.Client.Constructor));

   function Instance (C : Client_Session) return Client_Instance is
      (Client_Instance'(Device   => C.Instance.Private_X_Device,
                        Callback => C.Instance.Private_X_Callback,
                        Rw       => C.Instance.Private_X_Write,
                        Env      => C.Instance.Private_X_Env));

   function Initialized (C : Client_Session) return Boolean is
      (C.Instance.Private_X_Device /= System.Null_Address
       and then C.Instance.Private_X_Callback /= System.Null_Address
       and then C.Instance.Private_X_Write /= System.Null_Address
       and then C.Instance.Private_X_Env /= System.Null_Address);

   function Initialized (C : Client_Instance) return Boolean is
      (C.Device /= System.Null_Address
       and then C.Callback /= System.Null_Address
       and then C.Rw /= System.Null_Address
       and then C.Env /= System.Null_Address);

   function Writable (C : Client_Session) return Boolean is
      (Cxx.Block.Client.Writable (C.Instance) /= Cxx.Bool'Val (0));

   function Block_Count (C : Client_Session) return Count is
      (Count (Cxx.Block.Client.Block_Count (C.Instance)));

   function Block_Size (C : Client_Session) return Size is
      (Size (Cxx.Block.Client.Block_Size (C.Instance)));

   ----------------
   -- Dispatcher --
   ----------------

   function Create return Dispatcher_Session is
      (Dispatcher_Session'(Instance => Cxx.Block.Dispatcher.Constructor));

   function Initialized (D : Dispatcher_Session) return Boolean is
      (D.Instance.Root /= System.Null_Address
       and then D.Instance.Handler /= System.Null_Address);

   function Initialized (D : Dispatcher_Instance) return Boolean is
      (D.Root /= System.Null_Address
       and then D.Handler /= System.Null_Address);

   function Instance (D : Dispatcher_Session) return Dispatcher_Instance is
      (Dispatcher_Instance'(Root    => D.Instance.Root,
                            Handler => D.Instance.Handler));

   ------------
   -- Server --
   ------------

   function Null_Request return Server_Request is
      (Server_Request'(Request => Cxx.Block.Server.Request'(Kind         => -1,
                                                            Block_Number => 0,
                                                            Block_Count  => 0,
                                                            Success      => 0,
                                                            Offset       => 0,
                                                            Tag          => 0),
                       Status  => Componolit.Interfaces.Internal.Block.Raw));

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

   function Create return Server_Session is
      (Server_Session'(Instance => Cxx.Block.Server.Constructor));

   function Initialized (S : Server_Session) return Boolean is
      (S.Instance.Session /= System.Null_Address
       and then S.Instance.Callback /= System.Null_Address
       and then S.Instance.Block_Count /= System.Null_Address
       and then S.Instance.Block_Size /= System.Null_Address
       and then S.Instance.Writable /= System.Null_Address);

   function Initialized (S : Server_Instance) return Boolean is
      (S.Session /= System.Null_Address
       and then S.Callback /= System.Null_Address
       and then S.Block_Count /= System.Null_Address
       and then S.Block_Size /= System.Null_Address
       and then S.Writable /= System.Null_Address);

   function Instance (S : Server_Session) return Server_Instance is
      (Server_Instance'(Session     => S.Instance.Session,
                        Callback    => S.Instance.Callback,
                        Block_Count => S.Instance.Block_Count,
                        Block_Size  => S.Instance.Block_Size,
                        Writable    => S.Instance.Writable));

end Componolit.Interfaces.Block;
