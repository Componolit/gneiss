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

   --  Session status type
   --
   --  @value Uninitialized  The session is not initialized and no initialization is in progress.
   --  @value Pending        The session has startet its initialization and is waiting for the
   --                        server to accept or reject the request.
   --  @value Initialized    The session has been initialized and is ready for use.
   type Session_Status is (Uninitialized, Pending, Initialized);

   --  Identifier type to match session objects with meta data
   type Session_Index is range 0 .. 2 ** 24 - 1 with
      Size => 24;

   --  Option type to return a possibly invalid session index
   --
   --  @field Valid  Denotes if a valid session index is contained
   --  @field Value  Session index value if valid
   type Session_Index_Option (Valid : Boolean := False) is record
      case Valid is
         when True =>
            Value : Session_Index := 0;
         when False =>
            null;
      end case;
   end record with
      Size => 32;

   for Session_Index_Option use record
      Value at 0 range  0 .. 23;
      Valid at 0 range 24 .. 31;
   end record;

   --  Opaque system capability type
   type Capability is private;

private

   type Capability is new Gneiss_Internal.Capability;

end Gneiss;
