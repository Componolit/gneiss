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
   type Element is (<>);
   type Buffer_Index is range <>;
   type Buffer is array (Buffer_Index range <>) of Element;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory with
   SPARK_Mode
is
   pragma Compile_Time_Error (Element'Size /= 8,
                              "Size of Element must be 8 bit");

   type Client_Session is limited private;
   type Server_Session is limited private;
   type Dispatcher_Session is limited private;

   type Dispatcher_Capability is limited private;

   function Status (Session : Client_Session) return Session_Status;
   function Initialized (Session : Server_Session) return Boolean;
   function Initialized (Session : Dispatcher_Session) return Boolean;

   function Index (Session : Client_Session) return Session_Index_Option;
   function Index (Session : Server_Session) return Session_Index_Option;
   function Index (Session : Dispatcher_Session) return Session_Index_Option;

private

   type Client_Session is new Gneiss_Internal.Memory.Client_Session;
   type Server_Session is new Gneiss_Internal.Memory.Server_Session;
   type Dispatcher_Session is new Gneiss_Internal.Memory.Dispatcher_Session;
   type Dispatcher_Capability is new Gneiss_Internal.Memory.Dispatcher_Capability;

end Gneiss.Memory;
