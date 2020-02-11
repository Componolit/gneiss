--
--  @summary Shared memory client interface declarations
--  @author  Johannes Kliemann
--  @date    2020-02-05
--
--  Copyright (C) 2020 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

generic
   pragma Warnings (Off, "* is not referenced");
   with procedure Initialize_Event (Session : in out Client_Session);
   with procedure Modify (Session : in out Client_Session;
                          Data    : in out Buffer);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory.Client with
   SPARK_Mode
is

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Size    :        Long_Integer;
                         Idx     :        Session_Index := 1);

   procedure Modify (Session : in out Client_Session) with
      Pre => Status (Session) = Initialized;

   procedure Finalize (Session : in out Client_Session);

end Gneiss.Memory.Client;
