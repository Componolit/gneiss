with Cxx;
with Cxx.Configuration.Client;

package body Componolit.Interfaces.Rom with
   SPARK_Mode
is
   use type Cxx.Bool;

   function Initialized (C : Client_Session) return Boolean is
      (Cxx.Configuration.Client.Initialized (C.Instance) = Cxx.Bool'Val (1));

end Componolit.Interfaces.Rom;
