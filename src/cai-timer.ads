
private with Cai.Internal.Timer;

package Cai.Timer is

   type Time is new Duration;

   function "+" (Left : Time; Right : Duration) return Time is
      (Left + Time (Right));

   function "-" (Left : Time; Right : Duration) return Time is
      (Left - Time (Right));

   function "-" (Left : Time; Right : Time) return Duration is
      (Duration (Left - Right));

   type Client_Session is limited private;

private

   type Client_Session is new Cai.Internal.Timer.Client_Session;

end Cai.Timer;
