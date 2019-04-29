with Cai.Types;

package Cai.Timer.Client with
   SPARK_Mode
is

   --  Returns new session object
   --
   --  @return  Timer client session object
   function Create return Client_Session;

   --  Checks if session is initialized
   --
   --  @param C  Timer client session object
   --  @return   True if session is initialized else False
   function Initialized (C : Client_Session) return Boolean;

   --  Initialized timer session
   --
   --  @param C    Timer client session object
   --  @param Cap  System capability
   procedure Initialize (C : in out Client_Session; Cap : Cai.Types.Capability) with
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

   --  Finalizes timer session
   --
   --  @param C  Timer client session object
   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

end Cai.Timer.Client;
