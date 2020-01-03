--
--  @summary Log interface declarations
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss_Internal.Log;

package Gneiss.Log with
   SPARK_Mode
is

   --  Log client, dispatcher and server session objects
   type Client_Session is limited private;
   type Dispatcher_Session is limited private;
   type Server_Session is limited private;

   type Dispatcher_Capability is limited private;

   function Status (Session : Client_Session) return Session_Status;

   function Initialized (Session : Dispatcher_Session) return Boolean;

   function Initialized (Session : Server_Session) return Boolean;

   function Index (Session : Client_Session) return Session_Index with
      Pre => Status (Session) = Initialized;

   function Index (Session : Dispatcher_Session) return Session_Index with
      Pre => Initialized (Session);

   function Index (Session : Server_Session) return Session_Index with
      Pre => Initialized (Session);

private

   type Client_Session is new Gneiss_Internal.Log.Client_Session;
   type Dispatcher_Session is new Gneiss_Internal.Log.Dispatcher_Session;
   type Server_Session is new Gneiss_Internal.Log.Server_Session;
   type Dispatcher_Capability is new Gneiss_Internal.Log.Dispatcher_Capability;

end Gneiss.Log;
