--
--  @summary Timer client
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

generic
   --  Timer event
   with procedure Event;
package Gneiss.Timer.Client with
   SPARK_Mode
is

   --  Initialized timer session
   --
   --  @param C    Timer client session object
   --  @param Cap  System capability
   procedure Initialize (C   : in out Client_Session;
                         Cap :        Capability;
                         Idx :        Session_Index := 1);

   --  Returns a monotonic clock value
   --
   --  This function returns a monotonic rising clock value for each call.
   --  The returned value does not necessarily start at 0.
   --
   --  @param C  Timer client session object
   --  @return   Current clock value
   function Clock (C : Client_Session) return Time with
      Volatile_Function,
      Pre => Initialized (C);

   --  Sets the timeout after which the Event procedure will be called
   --
   --  The event procedure is called once after the time specified in this procedure.
   --  The precision of the actual timeout is platform dependent but the time is
   --  guaranteed to be AT LEAST the time specified in D.
   --  Only one timeout can be active at a time, if this procedure is called multiple times
   --  only the last call will be handled.
   --
   --  @param C  Timer client session object
   --  @param D  Timeout event duration
   procedure Set_Timeout (C : in out Client_Session;
                          D :        Duration) with
      Pre  => Initialized (C)
              and then D > 0.0,
      Post => Initialized (C);

   --  Finalizes timer session
   --
   --  @param C  Timer client session object
   procedure Finalize (C : in out Client_Session) with
      Post => not Initialized (C);

end Gneiss.Timer.Client;
