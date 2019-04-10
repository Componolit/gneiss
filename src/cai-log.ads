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

private with Cai.Internal.Log;

package Cai.Log with
   SPARK_Mode
is

   type Unsigned is mod 2 ** 64;
   --  Catch all mod type, only used for image functions

   function Image (V : Integer) return String with
      Post => Image'Result'Length <= 20 and Image'Result'First = 1;
   function Image (V : Long_Integer) return String with
      Post => Image'Result'Length <= 20 and Image'Result'First = 1;
   function Image (V : Boolean) return String with
      Post => Image'Result'Length <= 5 and Image'Result'First = 1;
   function Image (V : Unsigned) return String with
      Post => Image'Result'Length <= 16 and Image'Result'First = 1;
   function Image (V : Duration) return String with
      Post => Image'Result'Length <= 27 and Image'Result'First = 1;
   --  Image functions for basic types

   type Client_Session is limited private;
   --  Log client session object

private

   type Client_Session is new Cai.Internal.Log.Client_Session;

end Cai.Log;
