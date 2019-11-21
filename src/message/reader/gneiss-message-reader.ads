--
--  @summary Message reader interface
--  @author  Johannes Kliemann
--  @date    2019-11-12
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Gneiss.Types;

generic
   pragma Warnings (Off, "* is not referenced");
   --  Supress unreferenced warnings since not every platform needs this procedure

   --  Element type of the message buffer
   type Element is mod <>;
   --  Index type of the message buffer
   type Index is range <>;
   --  Message buffer type
   type Buffer is array (Index range <>) of Element;
   --  Size of a message
   Size : Index;

   --  Read event handler
   with procedure Event;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Message.Reader with
   SPARK_Mode
is

   pragma Compile_Time_Error (not (Element'Size mod 8 = 0),
                              "Only byte granular mod types are allowed");

   --  Fixed size message type
   subtype Message_Buffer is Buffer (Index'First .. Index'First + (Size - 1));

   --  Initialize message reader session
   --
   --  @param R  Reader session instance
   --  @param C  System capability
   --  @param L  Message channel label
   procedure Initialize (R : in out Reader_Session;
                         C :        Gneiss.Types.Capability;
                         L :        String);

   --  Check if a message is available in the channel
   --
   --  @param R  Reader session instance
   --  @return   True if a message is available
   function Available (R : Reader_Session) return Boolean with
      Pre => Initialized (R);

   --  Read a message from the channel
   --
   --  @param R  Reader session instance
   --  @param B  Message buffer
   procedure Read (R : in out Reader_Session;
                   B :    out Message_Buffer) with
      Pre  => Initialized (R)
              and then Available (R),
      Post => Initialized (R);

   --  Finalize reader session
   --
   --  @param R  Reader session instance
   procedure Finalize (R : in out Reader_Session);

end Gneiss.Message.Reader;
