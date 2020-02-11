
with Cxx;
with Cxx.Timer.Client;

package body Gneiss.Timer with
   SPARK_Mode
is

   use type Cxx.Bool;

   function Status (C : Client_Session) return Gneiss.Session_Status is
      (if Cxx.Timer.Client.Initialized (C.Instance) = Cxx.Bool'Val (1) then
          (if C.Instance.Index.Valid then Gneiss.Initialized else Gneiss.Pending)
       else
          Gneiss.Uninitialized);

   function Index (C : Client_Session) return Gneiss.Session_Index_Option is
      (C.Instance.Index);

end Gneiss.Timer;
