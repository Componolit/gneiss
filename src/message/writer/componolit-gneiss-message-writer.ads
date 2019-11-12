--
--  @summary Message writer interface
--  @author  Johannes Kliemann
--  @date    2019-11-12
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Componolit.Gneiss.Types;

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

   pragma Warnings (On, "* is not referenced");
package Componolit.Gneiss.Message.Writer with
   SPARK_Mode
is
   pragma Compile_Time_Error (not (Element'Size mod 8 = 0),
                              "Only byte granular mod types are allowed");

   --  Fixed size message type
   subtype Message_Buffer is Buffer (Index'First .. Index'First + (Size - 1));

   --  Initialize message writer session
   --
   --  @param W  Writer session instance
   --  @param C  System capability
   --  @param L  Message channel label
   procedure Initialize (W : in out Writer_Session;
                         C :        Componolit.Gneiss.Types.Capability;
                         L :        String);

   --  Write a message to the channel
   --
   --  @param W  Writer session instance
   --  @param B  Message buffer
   procedure Write (W : in out Writer_Session;
                    B :        Message_Buffer) with
      Pre  => Initialized (W),
      Post => Initialized (W);

   --  Finalize writer session
   --
   --  @param W  Writer session instance
   procedure Finalize (W : in out Writer_Session);

end Componolit.Gneiss.Message.Writer;
