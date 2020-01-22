--
--  @summary Memory interface declarations
--  @author  Johannes Kliemann
--  @date    2020-01-13
--
--  Copyright (C) 2020 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

generic
   pragma Warnings (Off, "* is not referenced");
   with procedure Event;
   with procedure Read (Session : in out Client_Session;
                        Data    :        Buffer);
   with procedure Modify (Session : in out Client_Session;
                          Data    : in out Buffer);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory.Client with
   SPARK_Mode
is

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Gneiss.Capability;
                         Label   :        String;
                         Mode    :        Access_Mode   := Read_Only;
                         Idx     :        Session_Index := 1);

   procedure Update (Session : in out Client_Session) with
      Pre => Status (Session) = Initialized;

   procedure Finalize (Session : in out Client_Session);

end Gneiss.Memory.Client;
