
with Cxx;
with Cxx.Timer.Client;

package body Gneiss.Timer with
   SPARK_Mode
is

   use type Cxx.Bool;

   function Initialized (Session : Client_Session) return Boolean is
      (Cxx.Timer.Client.Initialized (Session.Instance) = Cxx.Bool'Val (1)
       and then Session.Instance.Index.Valid);

   function Index (Session : Client_Session) return Gneiss.Session_Index_Option is
      (Session.Instance.Index);

end Gneiss.Timer;
