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

   --  Dispatcher capability used to enforce scope for dispatcher session procedures
   type Dispatcher_Capability is limited private;

   --  Check if session is initialized
   --
   --  @param Session  Client session instance
   --  @return         Initialization status
   function Initialized (Session : Client_Session) return Boolean;

   --  Check if session is initialized
   --
   --  @param Session  Dispatcher session instance
   --  @return         True if session is initialized
   function Initialized (Session : Dispatcher_Session) return Boolean;

   --  Check if session is initialized
   --
   --  @param Session  Server session instance
   --  @return         True if session is initialized
   function Initialized (Session : Server_Session) return Boolean;

   --  Get the index value that has been set on initialization
   --
   --  @param Session  Dispatcher session instance
   --  @return         Session index
   function Index (Session : Dispatcher_Session) return Session_Index_Option with
      Post => Initialized (Session) = Index'Result.Valid;

   --  Get the index value that has been set on initialization
   --
   --  @param Session  Server session instance
   --  @return         Session index
   function Index (Session : Server_Session) return Session_Index_Option with
      Post => Initialized (Session) = Index'Result.Valid;

private

   type Client_Session is new Gneiss_Internal.Log.Client_Session;
   type Dispatcher_Session is new Gneiss_Internal.Log.Dispatcher_Session;
   type Server_Session is new Gneiss_Internal.Log.Server_Session;
   type Dispatcher_Capability is new Gneiss_Internal.Log.Dispatcher_Capability;

end Gneiss.Log;
