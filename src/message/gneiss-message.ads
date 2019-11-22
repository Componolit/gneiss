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

private with Gneiss.Internal.Message;

generic
   type Index is range <>;
   type Byte is mod <>;
   type Buffer is array (Index range <>) of Byte;
   First  : Index;
   Length : Index;
package Gneiss.Message with
   SPARK_Mode
is

   subtype Message_Buffer is Buffer (First .. First + Length - 1);

   --  Client, Server and Dispatcher session objects
   type Client_Session is limited private;
   type Server_Session is limited private;
   type Dispatcher_Session is limited private;

   type Dispatcher_Capability is limited private;

   function State (Session : Client_Session) return Session_State;

   function State (Session : Server_Session) return Session_State;

   function State (Session : Dispatcher_Session) return Session_State;

private

   type Client_Session is new Gneiss.Internal.Message.Client_Session;
   type Server_Session is new Gneiss.Internal.Message.Server_Session;
   type Dispatcher_Session is new Gneiss.Internal.Message.Dispatcher_Session;
   type Dispatcher_Capability is new Gneiss.Internal.Message.Dispatcher_Capability;

end Gneiss.Message;
