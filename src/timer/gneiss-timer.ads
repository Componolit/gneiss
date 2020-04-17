--
--  @summary Timer interface
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

private with Gneiss_Internal.Timer;

--  WORKAROUND: Componolit/Workarounds#20
generic
package Gneiss.Timer with
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

   --  Gets the sessions current status
   --
   --  @param Session  Client session
   --  @return         Session status
   function Initialized (Session : Client_Session) return Boolean;

   --  Get the sessions index
   --
   --  @param Session  Client session
   --  @return         Index option that can be invalid
   function Index (Session : Client_Session) return Session_Index_Option with
      Post => (if Initialized (Session) then Index'Result.Valid);

private

   type Client_Session is new Gneiss_Internal.Timer.Client_Session;

end Gneiss.Timer;
