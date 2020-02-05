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
   with procedure Modify (Session : in out Server_Session;
                          Data    : in out Buffer);
   with procedure Initialize (Session : in out Server_Session);
   with procedure Finalize (Session : in out Server_Session);
   with function Ready (Session : Server_Session) return Boolean;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory.Server with
   SPARK_Mode
is

   procedure Modify (Session : in out Server_Session);

end Gneiss.Memory.Server;
