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
   --  Opaque message buffer, size must be 128 byte
   type Message_Buffer is private;
   --  Default message buffer value
   Null_Buffer : Message_Buffer;
package Gneiss.Message with
   SPARK_Mode
is
   --  WORKAROUND: Componolit/Workarounds#18
   --  pragma Compile_Time_Error (Message_Buffer'Size /= 128 * 8, "Buffer size must be 128 byte");

   --  Client, Server and Dispatcher session objects
   type Client_Session is limited private with
      Default_Initial_Condition => True;

   type Server_Session is limited private with
      Default_Initial_Condition => True;

   type Dispatcher_Session is limited private with
      Default_Initial_Condition => True;

   --  Dispatcher capability used to enforce scope for dispatcher session procedures
   type Dispatcher_Capability is limited private;

   --  Check initialization status
   --
   --  @param Session  Client session instance
   --  @return         Initialization status
   function Initialized (Session : Client_Session) return Boolean;

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
      Post => (if Initialized (Session) then Index'Result.Valid);

   --  Get the index value that has been set on initialization
   --
   --  @param Session  Server session instance
   --  @return         Session index
   function Index (Session : Server_Session) return Session_Index_Option with
      Post => (if Initialized (Session) then Index'Result.Valid);

   --  Get the index value that has been set on initialization
   --
   --  @param Session  Dispatcher session instance
   --  @return         Session index
   function Index (Session : Dispatcher_Session) return Session_Index_Option with
      Post => (if Initialized (Session) then Index'Result.Valid);

   --  Proof property that the dispatcher is registered on the platform
   --
   --  @param Session  Dispatcher session instance
   --  @return         Dispatcher is registered on the platform
   function Registered (Session : Dispatcher_Session) return Boolean with
      Ghost,
      Pre => Initialized (Session);

private

   package Internal is new Gneiss_Internal.Message (Message_Buffer, Null_Buffer);

   type Client_Session is new Internal.Client_Session;
   type Server_Session is new Internal.Server_Session;
   type Dispatcher_Session is new Internal.Dispatcher_Session;
   type Dispatcher_Capability is new Internal.Dispatcher_Capability;

end Gneiss.Message;
