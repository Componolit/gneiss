
private with Cai.Internal.Timer;

package Cai.Timer with
   SPARK_Mode
is

   type Time is new Duration;

   function "+" (Left : Time; Right : Duration) return Time is
      (Left + Time (Right)) with
      Pre => (if Right > 0.0 then Left < Time'Last - Time (Right))
             and (if Right < 0.0 then Left > Time'First - Time (Right));

   function "-" (Left : Time; Right : Duration) return Time is
      (Time (Left - Time (Right))) with
      Pre => (if Right > 0.0 then Left > Time'First + Time (Right))
             and (if Right < 0.0 then Left < Time'Last + Time (Right));

   type Client_Session is limited private;

private

   type Client_Session is new Cai.Internal.Timer.Client_Session;

end Cai.Timer;
