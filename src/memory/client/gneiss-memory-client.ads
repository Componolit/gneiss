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
   --  Initialization event handler
   --
   --  @param Session  Client session
   with procedure Initialize_Event (Session : in out Client_Session);

   --  Called to modify the shared memory buffer
   --
   --  @param Session  Client session
   --  @param Data     Shared memory buffer
   with procedure Modify (Session : in out Client_Session;
                          Data    : in out Buffer);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory.Client with
   SPARK_Mode
is

   --  Initialize client
   --
   --  @param Cap    System capability
   --  @param Label  Session label
   --  @param Size   Size of the shared memory buffer
   --  @param Idx    Session index
   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Size    :        Long_Integer;
                         Idx     :        Session_Index := 1);

   --  Access the shared memory buffer, this will call the passed Modify procedure
   --
   --  @param Session  Client session
   procedure Modify (Session : in out Client_Session) with
      Pre => Status (Session) = Initialized;

   --  Close session
   --
   --  @param Session  Client session
   procedure Finalize (Session : in out Client_Session);

end Gneiss.Memory.Client;
