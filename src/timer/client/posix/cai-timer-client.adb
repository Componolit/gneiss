
package body Cai.Timer.Client with
   SPARK_Mode => Off
is

   function Create return Client_Session
   is
   begin
      return False;
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
   begin
      return Boolean (C);
   end Initialized;

   procedure Initialize (C : in out Client_Session; Cap : Cai.Types.Capability)
   is
      pragma Unreferenced (Cap);
   begin
      C := True;
   end Initialize;

   function Clock (C : Client_Session) return Time
   is
      pragma Unreferenced (C);
      function C_Clock return Time with
         Volatile_Function,
         Import,
         Convention => C,
         External_Name => "timer_client_clock";
   begin
      return C_Clock;
   end Clock;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      C := False;
   end Finalize;

end Cai.Timer.Client;
