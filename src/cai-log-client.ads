--
--  @summary Log client interface
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Cai.Types;
package Cai.Log.Client with
   SPARK_Mode
is

   --  Checks if C is initialized
   --
   --  @param C  Client session instance
   --  @return True if C is initialized
   function Initialized (C : Client_Session) return Boolean;

   --  Create new Client_Session
   --
   --  @return Uninitialized client session
   function Create return Client_Session with
      Post => not Initialized (Create'Result);

   --  Intialize client
   --
   --  @param C               Client session instance
   --  @param Cap             System capability
   --  @param Label           Session label
   --  @param Message_Length  Requested maximum message length
   --                         This is a hint for the platform on how long messages the client wants to send
   --                         The platform is free to decide if it follows this hint
   --                         A value of 0 uses the platform default
   procedure Initialize (C              : in out Client_Session;
                         Cap            :        Cai.Types.Capability;
                         Label          :        String;
                         Message_Length :        Integer := 0);

   --  Finalize client session
   --
   --  @param C  Client session instance
   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

   --  Minimum message length, guaranteed by all platforms
   Minimum_Message_Length : constant Positive := 78 with Ghost;

   --  Maximum message length the platform can handle in a single message
   --
   --  @param C  Client session instance
   --  @return Maximal message length for Info, Warning and Error
   function Maximum_Message_Length (C : Client_Session) return Integer with
      Pre  => Initialized (C),
      Post => Maximum_Message_Length'Result > Minimum_Message_Length;

   --  Print info message
   --
   --  @param C        Client session instance
   --  @param Msg      Message to print
   --  @param Newline  Append a newline to the message
   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True) with
      Pre  => Initialized (C) and then (Msg'Length <= Minimum_Message_Length
                                        or else Msg'Length <= Maximum_Message_Length (C)),
      Post => Initialized (C)
              and Maximum_Message_Length (C)'Old = Maximum_Message_Length (C);

   --  Print warning message
   --
   --  @param C        Client session instance
   --  @param Msg      Message to print
   --  @param Newline  Append a newline to the message
   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True) with
      Pre  => Initialized (C) and then (Msg'Length <= Minimum_Message_Length
                                        or else Msg'Length <= Maximum_Message_Length (C)),
      Post => Initialized (C)
              and Maximum_Message_Length (C)'Old = Maximum_Message_Length (C);

   --  Print error message
   --
   --  @param C        Client session instance
   --  @param Msg      Message to print
   --  @param Newline  Append a newline to the message
   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True) with
      Pre  => Initialized (C) and then (Msg'Length <= Minimum_Message_Length
                                        or else Msg'Length <= Maximum_Message_Length (C)),
      Post => Initialized (C)
              and Maximum_Message_Length (C)'Old = Maximum_Message_Length (C);

   --  Flush all messages to make sure they're printed
   --
   --  @param C        Client session instance
   procedure Flush (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C)
              and Maximum_Message_Length (C)'Old = Maximum_Message_Length (C);

end Cai.Log.Client;
