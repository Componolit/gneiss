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

with Componolit.Interfaces.Types;

generic
   --  Component intialization procedure
   --
   --  @param Cap  Capability provided by the platform to use services
   with procedure Component_Construct (Capability : Componolit.Interfaces.Types.Capability);

   --  Component destruction procedure
   --  This procedure is called after Vacate has been called and the procedure Vacate has been called from returned.
   with procedure Component_Destruct;
package Componolit.Interfaces.Component with
   SPARK_Mode,
   Abstract_State => Platform,
   Initializes => Platform
is

   --  This package must only be instantiated once
   pragma Warnings (Off, "all instances of");

   type Component_Status is (Success, Failure);

   procedure Construct (Capability : Componolit.Interfaces.Types.Capability) with
      Export,
      Convention => C,
      External_Name => "componolit_interfaces_component_construct";

   procedure Destruct with
      Export,
      Convention => C,
      External_Name => "componolit_interfaces_component_destruct";

   procedure Vacate (Cap    : Componolit.Interfaces.Types.Capability;
                     Status : Component_Status) with
      Global => (In_Out => Platform);

   pragma Warnings (On, "all instances of");
end Componolit.Interfaces.Component;
