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

   --  Component destruction procedure
   --  This procedure is called after Vacate has been called and the procedure Vacate has been called from returned.
   with procedure Destruct;
package Cai.Component with
   SPARK_Mode,
   Abstract_State => Platform,
   Initializes => Platform
is

   type Component_Status is (Success, Failure);

   procedure Vacate (Cap    : Cai.Types.Capability;
                     Status : Component_Status) with
      Global => (In_Out => Platform);

end Cai.Component;
