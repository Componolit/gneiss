--
--  @summary Message interface declarations
--  @author  Johannes Kliemann
--  @date    2019-11-12
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss_Internal.Message;

generic
   type Index is range <>;
   type Byte is mod <>;
   type Buffer is array (Index range <>) of Byte;
   First  : Index;
   Length : Index;
package Gneiss.Message with
   SPARK_Mode
is
   pragma Compile_Time_Error (Byte'Size /= 8, "Byte size must be 8 bit");

   subtype Message_Buffer is Buffer (First .. First + Length - 1);

   --  Client, Server and Dispatcher session objects
   type Client_Session is limited private;
   type Server_Session is limited private;
   type Dispatcher_Session is limited private;

   type Dispatcher_Capability is limited private;

   function Status (Session : Client_Session) return Session_Status;

   function Status (Session : Server_Session) return Session_Status;

   function Status (Session : Dispatcher_Session) return Session_Status;

private

   type Client_Session is new Gneiss_Internal.Message.Client_Session;
   type Server_Session is new Gneiss_Internal.Message.Server_Session;
   type Dispatcher_Session is new Gneiss_Internal.Message.Dispatcher_Session;
   type Dispatcher_Capability is new Gneiss_Internal.Message.Dispatcher_Capability;

end Gneiss.Message;
