--
--  @summary Gneiss top package
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss_Internal;

package Gneiss with
   SPARK_Mode
is

   type Session_Status is (Uninitialized, Pending, Initialized);

   type Session_Index is range 0 .. 2 ** 32 - 1;

   type Capability is private;

   Invalid_Index : constant Session_Index := 0;

private

   type Capability is new Gneiss_Internal.Capability;

end Gneiss;
