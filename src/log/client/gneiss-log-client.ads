--
--  @summary Log client interface
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

package Gneiss.Log.Client with
   SPARK_Mode
is

   --  Intialize client
   --
   --  @param C               Client session instance
   --  @param Cap             System capability
   --  @param Label           Session label
   procedure Initialize (C              : in out Client_Session;
                         Cap            :        Capability;
                         Label          :        String);

   --  Finalize client session
   --
   --  @param C  Client session instance
   procedure Finalize (C : in out Client_Session) with
      Post => not Initialized (C);

   --  Print info message
   --
   --  @param C        Client session instance
   --  @param Msg      Message to print
   --  @param Newline  Append a newline to the message
   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True) with
      Pre  => Initialized (C),
      Post => Initialized (C);

   --  Print warning message
   --
   --  @param C        Client session instance
   --  @param Msg      Message to print
   --  @param Newline  Append a newline to the message
   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True) with
      Pre  => Initialized (C),
      Post => Initialized (C);

   --  Print error message
   --
   --  @param C        Client session instance
   --  @param Msg      Message to print
   --  @param Newline  Append a newline to the message
   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True) with
      Pre  => Initialized (C),
      Post => Initialized (C);

   --  Flush all messages to make sure they're printed
   --
   --  @param C        Client session instance
   procedure Flush (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C);

end Gneiss.Log.Client;
