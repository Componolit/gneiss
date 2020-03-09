--
--  @summary Message client interface declarations
--  @author  Johannes Kliemann
--  @date    2019-11-12
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

generic
   --  Message received event
   with procedure Event;
package Gneiss.Message.Client with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   --  Intialize client
   --
   --  @param Session Client session instance
   --  @param Cap     System capability
   --  @param Label   Session label
   --  @param Idx     Session index
   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1);

   --  Finalize client session
   --
   --  @param Session  Client session instance
   procedure Finalize (Session : in out Client_Session) with
      Post => not Initialized (Session);

   --  Check if message is available
   --
   --  @param Session  Client session instance
   --  @return         True if message is available
   function Available (Session : Client_Session) return Boolean with
      Pre => Initialized (Session);

   --  Write message
   --
   --  @param Session  Client session instance
   --  @param Content  Message
   procedure Write (Session : in out Client_Session;
                    Content :        Message_Buffer) with
      Pre  => Initialized (Session),
      Post => Initialized (Session);

   --  Read message
   --
   --  @param Session  Client session instance
   --  @param Content  Message
   procedure Read (Session : in out Client_Session;
                   Content :    out Message_Buffer) with
      Pre  => Initialized (Session)
              and then Available (Session),
      Post => Initialized (Session);

end Gneiss.Message.Client;
