
with C;
with System;

package body Gneiss.Block with
   SPARK_Mode
is
   use type System.Address;

   ------------
   -- Client --
   ------------

   function Initialized (C : Client_Session) return Boolean is
      (C.Event /= System.Null_Address
       and then C.Rw /= System.Null_Address
       and then C.Fd > -1);

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

   function Initialized (S : Server_Session) return Boolean is
      (False);

   function Valid (S : Server_Session) return Boolean is
      (False);

   function Identifier (S : Server_Session) return Session_Id is
      (Session_Id'First);

end Gneiss.Block;
