--
--  @summary Component construction interface
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Cai.Types;

generic
   with procedure Construct (Cap : Cai.Types.Capability);
   --  Component initialization procedure, only called once
   --  only source of an initialized Capability object
   --
   --  @param Cap  System capability
package Cai.Component is

   pragma Elaborate_Body;

end Cai.Component;
