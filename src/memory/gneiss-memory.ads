--
--  @summary Shared memory interface declarations
--  @author  Johannes Kliemann
--  @date    2020-02-05
--
--  Copyright (C) 2020 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss_Internal.Memory;

generic
   pragma Warnings (Off, "* is not referenced");

   --  Buffer element type, must be 8 bit in size
   type Element is (<>);

   --  Buffer index type
   type Buffer_Index is range <>;

   --  Buffer array type
   type Buffer is array (Buffer_Index range <>) of Element;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory with
   SPARK_Mode
is
   pragma Compile_Time_Error (Element'Size /= 8,
                              "Size of Element must be 8 bit");

   --  Session types
   type Client_Session is limited private;
   type Server_Session is limited private;
   type Dispatcher_Session is limited private;

   --  Dispatcher capability, used to enforce scope for dispatcher procedures
   type Dispatcher_Capability is limited private;

   --  Gets the sessions current status
   --
   --  @param Session  Client session
   --  @return         Session status
   function Initialized (Session : Client_Session) return Boolean;

   --  Check if session is initialized
   --
   --  @param Session  Server session
   --  @return         True if the server session is initialized
   function Initialized (Session : Server_Session) return Boolean;

   --  Check if session is initialized
   --
   --  @param Session  Dispatcher session
   --  @return         True if the server session is initialized
   function Initialized (Session : Dispatcher_Session) return Boolean;

   --  Get the sessions index
   --
   --  @param Session  Client session
   --  @return         Index option that can be invalid
   function Index (Session : Client_Session) return Session_Index_Option;

   --  Get the sessions index
   --
   --  @param Session  Server session
   --  @return         Index option that can be invalid
   function Index (Session : Server_Session) return Session_Index_Option;

   --  Get the sessions index
   --
   --  @param Session  Dispatcher session
   --  @return         Index option that can be invalid
   function Index (Session : Dispatcher_Session) return Session_Index_Option;

   --  Proof property that the dispatcher is registered on the platform
   --
   --  @param Session  Dispatcher session instance
   --  @return         Dispatcher is registered on the platform
   function Registered (Session : Dispatcher_Session) return Boolean with
      Ghost,
      Pre => Initialized (Session);

private

   type Client_Session is new Gneiss_Internal.Memory.Client_Session;
   type Server_Session is new Gneiss_Internal.Memory.Server_Session;
   type Dispatcher_Session is new Gneiss_Internal.Memory.Dispatcher_Session;
   type Dispatcher_Capability is new Gneiss_Internal.Memory.Dispatcher_Capability;

end Gneiss.Memory;
