
with Ada.Unchecked_Conversion;
with Interfaces;
with Musinfo;
with Musinfo.Instance;

package body Componolit.Interfaces.Timer.Client with
   SPARK_Mode
is

   function Create return Client_Session
   is
   begin
      return Client_Session'(Initialized => False);
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
   begin
      return C.Initialized;
   end Initialized;

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Interfaces.Types.Capability)
   is
      pragma Unreferenced (Cap);
   begin
      C.Initialized := True;
   end Initialize;

   function Clock (C : Client_Session) return Time
   is
      pragma Unreferenced (C);
      use type Standard.Interfaces.Unsigned_64;
      Microsecs : constant Standard.Interfaces.Unsigned_64 :=
         Musinfo.Instance.TSC_Schedule_Start / (Musinfo.Instance.TSC_Khz / 1000);
      function To_Time is new Ada.Unchecked_Conversion (Standard.Interfaces.Unsigned_64, Time);
   begin
      return To_Time (Microsecs);
   end Clock;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      C.Initialized := False;
   end Finalize;

end Componolit.Interfaces.Timer.Client;
