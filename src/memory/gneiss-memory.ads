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

private with Gneiss_Internal.Memory;

generic
   type Element is (<>);
   type Index is range <>;
   type Buffer is array (Index range <>) of Element;
package Gneiss.Memory with
   SPARK_Mode
is
   pragma Compile_Time_Error (Element'Size /= 8,
                              "Size of Element must be 8 bit");

   type Access_Mode is (Read_Only, Read_Write);

   type Client_Session is limited private;

   function Status (Session : Client_Session) return Session_Status;

   function Index (Session : Client_Session) return Session_Index;

private

   type Client_Session is new Gneiss_Internal.Memory.Client_Session;

end Gneiss.Memory;
