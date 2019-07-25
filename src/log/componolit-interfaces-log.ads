--
--  @summary Log interface declarations
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Componolit.Interfaces.Internal.Log;

package Componolit.Interfaces.Log with
   SPARK_Mode
is

   --  Log client session object
   type Client_Session is limited private;

private

   type Client_Session is new Componolit.Interfaces.Internal.Log.Client_Session;

end Componolit.Interfaces.Log;
