--
--  @summary Memory server interface
--  @author  Johannes Kliemann
--  @date    2020-02-05
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

generic
   pragma Warnings (Off, "* is not referenced");

   --  Called to modify the shared memory buffer
   --
   --  @param Session  Server session
   --  @param Data     Shared memory buffer
   with procedure Modify (Session : in out Server_Session;
                          Data    : in out Buffer);
   --  Called when a client requests to initialize a server
   --
   --  @param Session  Server session
   with procedure Initialize (Session : in out Server_Session);

   --  Called when the client disconnects
   --
   --  @param Session  Server session
   with procedure Finalize (Session : in out Server_Session);

   --  Called to check if the server implementation is ready to server requests
   --
   --  @param Session  Server session
   --  @return         True if the server is ready to serve requests
   with function Ready (Session : Server_Session) return Boolean;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory.Server with
   SPARK_Mode
is

   --  Access the shared memory buffer, this will call the passed Modify procedure
   --
   --  @param Session  Server session
   procedure Modify (Session : in out Server_Session);

end Gneiss.Memory.Server;
