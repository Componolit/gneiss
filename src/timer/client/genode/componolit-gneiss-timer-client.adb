
with Cxx;
with Cxx.Timer.Client;

package body Componolit.Gneiss.Timer.Client
is

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Gneiss.Types.Capability) with
      SPARK_Mode => Off
   is
   begin
      if Initialized (C) then
         return;
      end if;
      Cxx.Timer.Client.Initialize (C.Instance, Cap, Event'Address);
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
      if not Initialized (C) then
         return;
      end if;
      Cxx.Timer.Client.Finalize (C.Instance);
   end Finalize;

end Componolit.Gneiss.Timer.Client;
