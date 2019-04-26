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
   --  Component intialization procedure
   --
   --  @param Cap  Capability provided by the platform to use services
   with procedure Construct (Cap : Cai.Types.Capability);
package Cai.Component is

   type Shutdown_Status is (Success, Failure);

   procedure Shutdown (Cap    : Cai.Types.Capability;
                       Status : Shutdown_Status);

end Cai.Component;
