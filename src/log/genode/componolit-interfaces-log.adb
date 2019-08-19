
with Cxx;
with Cxx.Log.Client;

package body Componolit.Interfaces.Log with
   SPARK_Mode
is
   use type Cxx.Bool;

   function Create return Client_Session is
      (Client_Session'(Instance => Cxx.Log.Client.Constructor));

   function Initialized (C : Client_Session) return Boolean is
      (Cxx.Log.Client.Initialized (C.Instance) = Cxx.Bool'Val (1));

   function Maximum_Message_Length (C : Client_Session) return Integer is
      (Integer (Cxx.Log.Client.Maximum_Message_Length (C.Instance)));

end Componolit.Interfaces.Log;
