--
--  @summary Message server interface declarations
--  @author  Johannes Kliemann
--  @date    2019-11-12
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

generic
   pragma Warnings (Off, "* is not referenced");
   --  Supress unreferenced warnings since not every platform needs each subprogram

   --  Called when the status of the message channel changed
   with procedure Event;
   --  Custom initialization for the server,
   --  automatically called by Gneiss.Block.Dispatcher.Session_Accept
   --
   --  @param Session  Server session instance
   with procedure Initialize (Session : in out Server_Session);
   --  Custom finalization for the server
   --
   --  Is automatically called by Gneiss.Block.Dispatcher.Session_Cleanup
   --  when the connected client disconnects.
   --
   --  @param S  Server session instance
   with procedure Finalize (Session : in out Server_Session);
   --  Checks if the server implementation is ready
   --
   --  @param S  Server session instance
   --  @return   True if the server implementation is ready
   with function Ready (Session : Server_Session) return Boolean;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Message.Server with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   --  Check if message is available
   --
   --  @param Session  Server session instance
   --  @return         True if message is available
   function Available (Session : Server_Session) return Boolean with
      Pre => Ready (Session)
             and then Initialized (Session);

   --  Write message
   --
   --  @param Session  Server session instance
   --  @param Data     Message
   procedure Write (Session : in out Server_Session;
                    Data    :        Message_Buffer) with
      Pre  => Ready (Session)
              and then Initialized (Session),
      Post => Ready (Session)
              and then Initialized (Session);

   --  Read message
   --
   --  @param Session  Server session instance
   --  @param Data     Message
   procedure Read (Session : in out Server_Session;
                   Data    :    out Message_Buffer) with
      Pre  => Ready (Session)
              and then Initialized (Session)
              and then Available (Session),
      Post => Ready (Session)
              and then Initialized (Session);

end Gneiss.Message.Server;
