
with Cxx;
with Cxx.Timer.Client;

package body Gneiss.Timer.Client
is

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Capability;
                         Idx :        Session_Index := 1) with
      SPARK_Mode => Off
   is
      use type Cxx.Bool;
   begin
      if Status (C) in Initialized | Pending then
         return;
      end if;
      Cxx.Timer.Client.Initialize (C.Instance, Cap, Event'Address, Initialize_Event'Address);
      if Cxx.Timer.Client.Initialized (C.Instance) = Cxx.Bool'Val (1) then
         C.Instance.Index := Session_Index_Option'(Valid => True, Value => Idx);
      end if;
   end Initialize;

   function Clock (C : Client_Session) return Time
   is
   begin
      return Time (Cxx.Timer.Client.Clock (C.Instance));
   end Clock;

   procedure Set_Timeout (C : in out Client_Session;
                          D :        Duration)
   is
   begin
      Cxx.Timer.Client.Set_Timeout (C.Instance, D);
   end Set_Timeout;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      if Status (C) = Uninitialized then
         return;
      end if;
      Cxx.Timer.Client.Finalize (C.Instance);
   end Finalize;

end Gneiss.Timer.Client;
