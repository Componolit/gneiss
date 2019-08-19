with Cxx;
with Cxx.Configuration.Client;

package body Componolit.Interfaces.Rom with
   SPARK_Mode
is
   use type Cxx.Bool;

   function Create return Client_Session is
      (Client_Session'(Instance => Cxx.Configuration.Client.Constructor));

   function Initialized (C : Client_Session) return Boolean is
      (Cxx.Configuration.Client.Initialized (C.Instance) = Cxx.Bool'Val (1));

end Componolit.Interfaces.Rom;
