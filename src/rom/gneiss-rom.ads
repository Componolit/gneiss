--
--  @summary Rom interface declarations
--  @author  Johannes Kliemann
--  @date    2020-01-13
--
--  Copyright (C) 2020 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss_Internal.Rom;

generic
   pragma Warnings (Off, "* is not referenced");
   type Element is (<>);
   type Buffer_Index is range <>;
   type Buffer is array (Buffer_Index range <>) of Element;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Rom with
   SPARK_Mode
is
   pragma Compile_Time_Error (Element'Size /= 8,
                              "Size of Element must be 8 bit");

   type Client_Session is limited private;

   function Status (Session : Client_Session) return Session_Status;

   function Index (Session : Client_Session) return Session_Index_Option;

private

   type Client_Session is new Gneiss_Internal.Rom.Client_Session;

end Gneiss.Rom;
