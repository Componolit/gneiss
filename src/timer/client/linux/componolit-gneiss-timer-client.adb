
with System;

package body Componolit.Gneiss.Timer.Client
is

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Gneiss.Types.Capability) with
      SPARK_Mode => Off
   is
      procedure C_Initialize (Session    : in out System.Address;
                              Capability :        Componolit.Gneiss.Types.Capability;
                              Callback   :        System.Address) with
         Import,
         Convention => C,
         External_Name => "timer_client_initialize";
   begin
      if not Initialized (C) then
         C_Initialize (C.Instance, Cap, Event'Address);
      end if;
   end Initialize;

   function Clock (C : Client_Session) return Time with
      SPARK_Mode => Off
   is
      pragma Unreferenced (C);
      function C_Clock return Time with
         Volatile_Function,
         Import,
         Convention    => C,
         External_Name => "timer_client_clock",
         Global        => null;
   begin
      return C_Clock;
   end Clock;

   procedure Set_Timeout (C : in out Client_Session;
                          D :        Duration)
   is
      procedure C_Timeout (Session : System.Address;
                           Dur     : Duration) with
         Import,
         Convention    => C,
         External_Name => "timer_client_set_timeout",
         Global        => null;
   begin
      C_Timeout (C.Instance, D);
   end Set_Timeout;

   procedure Finalize (C : in out Client_Session)
   is
      procedure C_Finalize (Session : in out System.Address) with
         Import,
         Convention    => C,
         External_Name => "timer_client_finalize",
         Global        => null;
   begin
      if Initialized (C) then
         C_Finalize (C.Instance);
         C.Instance := System.Null_Address;
      end if;
   end Finalize;

end Componolit.Gneiss.Timer.Client;
