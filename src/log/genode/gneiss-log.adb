
with Cxx;
with Cxx.Log.Client;

package body Gneiss.Log with
   SPARK_Mode
is
   use type Cxx.Bool;

   function Initialized (C : Client_Session) return Boolean is
      (Cxx.Log.Client.Initialized (C.Instance) = Cxx.Bool'Val (1)
       and then C.Cursor in C.Buffer'Range);

end Gneiss.Log;
