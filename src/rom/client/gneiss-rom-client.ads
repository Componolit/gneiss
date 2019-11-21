--
--  @summary Rom client interface
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Gneiss.Types;

generic
   type Element is private;
   type Index is range <>;
   type Buffer is array (Index range <>) of Element;
   with procedure Parse (Data : Buffer);
package Gneiss.Rom.Client with
   SPARK_Mode
is
   pragma Warnings (Off, "procedure ""Parse"" is not referenced");

   procedure Initialize (C    : in out Client_Session;
                         Cap  :        Gneiss.Types.Capability;
                         Name :        String := "");

   procedure Load (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C);

   procedure Finalize (C : in out Client_Session) with
      Post => not Initialized (C);

   pragma Warnings (On, "procedure ""Parse"" is not referenced");
end Gneiss.Rom.Client;
