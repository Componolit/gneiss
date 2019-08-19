
with Cxx;
with Cxx.Timer.Client;

package body Componolit.Interfaces.Timer with
   SPARK_Mode
is

   use type Cxx.Bool;

   function Create return Client_Session is
      (Client_Session'(Instance => Cxx.Timer.Client.Constructor));

   function Initialized (C : Client_Session) return Boolean is
      (Cxx.Timer.Client.Initialized (C.Instance) = Cxx.Bool'Val (1));

end Componolit.Interfaces.Timer;
