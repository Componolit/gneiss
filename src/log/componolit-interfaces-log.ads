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

   --  Checks if C is initialized
   --
   --  @param C  Client session instance
   --  @return True if C is initialized
   function Initialized (C : Client_Session) return Boolean;

   --  Minimum message length, guaranteed by all platforms
   Minimum_Message_Length : constant Positive := 78 with Ghost;

   --  Maximum message length the platform can handle in a single message
   --
   --  @param C  Client session instance
   --  @return Maximum message length for Info, Warning and Error
   function Maximum_Message_Length (C : Client_Session) return Integer with
     Annotate => (GNATprove, Terminating),
      Pre  => Initialized (C),
      Post => Maximum_Message_Length'Result > Minimum_Message_Length;

private

   type Client_Session is new Componolit.Interfaces.Internal.Log.Client_Session;

end Componolit.Interfaces.Log;
