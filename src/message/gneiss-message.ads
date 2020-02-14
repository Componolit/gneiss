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
   type Message_Buffer is private;
   Null_Buffer : Message_Buffer;
package Gneiss.Message with
   SPARK_Mode
is
   pragma Compile_Time_Error (Message_Buffer'Size /= 128 * 8, "Buffer size must be 128 byte");

   --  Client, Server and Dispatcher session objects
   type Client_Session is limited private;
   type Server_Session is limited private;
   type Dispatcher_Session is limited private;

   --  Dispatcher capability used to enforce scope for dispatcher session procedures
   type Dispatcher_Capability is limited private;

   --  Check initialization status
   --
   --  @param Session  Client session instance
   --  @return         Initialization status
   function Status (Session : Client_Session) return Session_Status;

   --  Check if session is initialized
   --
   --  @param Session  Server session instance
   --  @return         True if session is initialized
   function Initialized (Session : Server_Session) return Boolean;

   --  Check if session is initialized
   --
   --  @param Session  Dispatcher session instance
   --  @return         True if session is initialized
   function Initialized (Session : Dispatcher_Session) return Boolean;

   --  Get the index value that has been set on initialization
   --
   --  @param Session  Client session instance
   --  @return         Session index
   function Index (Session : Client_Session) return Session_Index_Option with
      Post => (Status (Session) in Initialized | Pending) = Index'Result.Valid;

   --  Get the index value that has been set on initialization
   --
   --  @param Session  Server session instance
   --  @return         Session index
   function Index (Session : Server_Session) return Session_Index_Option with
      Post => Initialized (Session) = Index'Result.Valid;

   --  Get the index value that has been set on initialization
   --
   --  @param Session  Dispatcher session instance
   --  @return         Session index
   function Index (Session : Dispatcher_Session) return Session_Index_Option with
      Post => Initialized (Session) = Index'Result.Valid;

private

   package Internal is new Gneiss_Internal.Message (Message_Buffer, Null_Buffer);

   type Client_Session is new Internal.Client_Session;
   type Server_Session is new Internal.Server_Session;
   type Dispatcher_Session is new Internal.Dispatcher_Session;
   type Dispatcher_Capability is new Internal.Dispatcher_Capability;

end Gneiss.Message;
