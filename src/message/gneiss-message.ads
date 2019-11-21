--
--  @summary Message interface declarations
--  @author  Johannes Kliemann
--  @date    2019-11-12
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss.Internal.Message;

package Gneiss.Message with
   SPARK_Mode
is

   --  Reader and Writer session objects
   type Writer_Session is limited private;
   type Reader_Session is limited private;

   --  Checks if W is initialized
   --
   --  @param W  Writer session instance
   --  @return   True if W is initialized
   function Initialized (W : Writer_Session) return Boolean;

   --  Checks if R is initialized
   --
   --  @param R  Reader session instance
   --  @return   True if R is initialized
   function Initialized (R : Reader_Session) return Boolean;

private

   type Writer_Session is new Gneiss.Internal.Message.Writer_Session;
   type Reader_Session is new Gneiss.Internal.Message.Reader_Session;

end Gneiss.Message;
