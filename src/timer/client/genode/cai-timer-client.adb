
with Cxx;
with Cxx.Timer.Client;

package body Cai.Timer.Client with
   SPARK_Mode => Off
is

   function Create return Client_Session
   is
   begin
      return Client_Session'(Instance => Cxx.Timer.Client.Constructor);
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
      use type Cxx.Bool;
   begin
      return Cxx.Timer.Client.Initialized (C.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Cai.Types.Capability)
   is
   begin
      Cxx.Timer.Client.Initialize (C.Instance, Cap);
   end Initialize;

   function Clock (C : Client_Session) return Time
   is
   begin
      return Time (Cxx.Timer.Client.Clock (C.Instance)) / 1000000;
   end Clock;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Cxx.Timer.Client.Finalize (C.Instance);
   end Finalize;

end Cai.Timer.Client;
