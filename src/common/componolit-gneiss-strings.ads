--
--  @summary String operation instances for common types
--  @author  Johannes Kliemann
--  @date    2019-07-25
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Interfaces;
with Componolit.Gneiss.Strings_Generic;

package Componolit.Gneiss.Strings with
   SPARK_Mode
is

   --  Image instances for the most common ranged and modular types
   function Image is new Strings_Generic.Image_Ranged (Integer);
   function Image is new Strings_Generic.Image_Ranged (Long_Integer);
   function Image is new Strings_Generic.Image_Modular (Standard.Interfaces.Unsigned_8);
   function Image is new Strings_Generic.Image_Modular (Standard.Interfaces.Unsigned_16);
   function Image is new Strings_Generic.Image_Modular (Standard.Interfaces.Unsigned_32);
   function Image is new Strings_Generic.Image_Modular (Standard.Interfaces.Unsigned_64);

   --  Image function for Boolean
   --
   --  @param V  Boolean value
   --  @return   String "True" or "False"
   function Image (V : Boolean) return String with
      Post => Image'Result'Length <= 5 and Image'Result'First = 1;

   --  Image function for Duration
   --
   --  @param V  Duration value
   --  @param    Duration as string with 6 decimals
   function Image (V : Duration) return String with
      Post => Image'Result'Length <= 28 and Image'Result'First = 1;

end Componolit.Gneiss.Strings;
