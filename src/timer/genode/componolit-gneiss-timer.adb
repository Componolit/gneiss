
with Cxx;
with Cxx.Timer.Client;

package body Componolit.Gneiss.Timer with
   SPARK_Mode
is

   use type Cxx.Bool;

   function Initialized (C : Client_Session) return Boolean is
      (Cxx.Timer.Client.Initialized (C.Instance) = Cxx.Bool'Val (1));

end Componolit.Gneiss.Timer;
