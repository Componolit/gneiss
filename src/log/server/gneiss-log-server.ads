--
--  @summary Log server interface
--  @author  Johannes Kliemann
--  @date    2020-01-07
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

generic
   pragma Warnings (Off, "* is not referenced");
   --  Supress unreferenced warnings since not every platform needs each subprogram

   --  Called when data needs to be written
   --
   --  @param Session  Server session instance
   --  @param Data     Data that needs to be written
   with procedure Write (Session : in out Server_Session;
                         Data    :        String);
   --  Custom initialization for the server,
   --  automatically called by Gneiss.Block.Dispatcher.Session_Accept
   --
   --  @param Session  Server session instance
   with procedure Initialize (Session : in out Server_Session);
   --  Custom finalization for the server
   --
   --  Is automatically called by Gneiss.Block.Dispatcher.Session_Cleanup
   --  when the connected client disconnects.
   --
   --  @param S  Server session instance
   with procedure Finalize (Session : in out Server_Session);
   --  Checks if the server implementation is ready
   --
   --  @param S  Server session instance
   --  @return   True if the server implementation is ready
   with function Ready (Session : Server_Session) return Boolean;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Log.Server with
   SPARK_Mode
is

end Gneiss.Log.Server;
