with Componolit.Interfaces.Types;

generic
   with procedure Event;
package Componolit.Interfaces.Timer.Client with
   SPARK_Mode
is

   --  Initialized timer session
   --
   --  @param C    Timer client session object
   --  @param Cap  System capability
   procedure Initialize (C : in out Client_Session; Cap : Componolit.Interfaces.Types.Capability) with
      Pre => not Initialized (C);

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
      Pre  => Initialized (C),
      Post => not Initialized (C);

end Componolit.Interfaces.Timer.Client;
