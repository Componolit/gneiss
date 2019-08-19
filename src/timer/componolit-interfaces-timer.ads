
private with Componolit.Interfaces.Internal.Timer;

package Componolit.Interfaces.Timer with
   SPARK_Mode
is

   --  Duration compatible time type
   type Time is new Duration;

   --  "+" operator for Time and Duration
   --
   --  @param Left   Time
   --  @param Right  Time difference
   --  @return       Time
   function "+" (Left : Time; Right : Duration) return Time is
      (Left + Time (Right)) with
      Pre => (if Right > 0.0 then Left < Time'Last - Time (Right))
             and (if Right < 0.0 then Left > Time'First - Time (Right));

   --  "-" operator for Time and Duration
   --
   --  @param Left   Time
   --  @param Right  Time difference
   --  @return       Time
   function "-" (Left : Time; Right : Duration) return Time is
      (Time (Left - Time (Right))) with
      Pre => (if Right > 0.0 then Left > Time'First + Time (Right))
             and (if Right < 0.0 then Left < Time'Last + Time (Right));

   --  Timer client session object
   type Client_Session is limited private;

   --  Returns new session object
   --
   --  @return  Timer client session object
   function Create return Client_Session;

   --  Checks if session is initialized
   --
   --  @param C  Timer client session object
   --  @return   True if session is initialized else False
   function Initialized (C : Client_Session) return Boolean;

private

   type Client_Session is new Componolit.Interfaces.Internal.Timer.Client_Session;

end Componolit.Interfaces.Timer;
