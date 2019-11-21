--
--  @summary Log interface declarations
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss.Internal.Log;

package Gneiss.Log with
   SPARK_Mode
is

   --  Log client session object
   type Client_Session is limited private;

   --  Checks if C is initialized
   --
   --  @param C  Client session instance
   --  @return True if C is initialized
   function Initialized (C : Client_Session) return Boolean;

private

   type Client_Session is new Gneiss.Internal.Log.Client_Session;

end Gneiss.Log;
