--
--  @summary Interface type declarations
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Componolit.Interfaces.Internal.Types;
package Componolit.Interfaces.Types is

   --  System capability
   type Capability is private;

private

   type Capability is new Componolit.Interfaces.Internal.Types.Capability;

end Componolit.Interfaces.Types;
