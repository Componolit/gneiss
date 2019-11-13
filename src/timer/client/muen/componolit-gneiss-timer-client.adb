
with Ada.Unchecked_Conversion;
with System;
with Interfaces;
with Musinfo;
with Musinfo.Instance;
with Componolit.Gneiss.Muen;
with Componolit.Gneiss.Muen_Registry;

package body Componolit.Gneiss.Timer.Client with
   SPARK_Mode
is
   package CIM renames Componolit.Gneiss.Muen;
   package Reg renames Componolit.Gneiss.Muen_Registry;

   procedure Check_Event (I : CIM.Session_Index);

   function Event_Address return System.Address;

   function Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Check_Event'Address;
   end Event_Address;

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Gneiss.Types.Capability)
   is
      pragma Unreferenced (Cap);
      use type CIM.Async_Session_Type;
   begin
      if Initialized (C) or else not Musinfo.Instance.Is_Valid then
         return;
      end if;
      for I in Reg.Registry'Range loop
         if Reg.Registry (I).Kind = CIM.None then
            Reg.Registry (I) := Reg.Session_Entry'(Kind          => CIM.Timer_Client,
                                                   Next_Timeout  => 0,
                                                   Timeout_Set   => False,
                                                   Timeout_Event => Event_Address);
            C.Index := I;
            exit;
         end if;
      end loop;
   end Initialize;

   function Clock (C : Client_Session) return Time
   is
      pragma Unreferenced (C);
      use type Standard.Interfaces.Unsigned_64;
      function To_Time is new Ada.Unchecked_Conversion (Standard.Interfaces.Unsigned_64, Time);
      Start : constant Interfaces.Unsigned_64 := Musinfo.Instance.TSC_Schedule_Start;
   begin
      return To_Time (Start * 1000 / (Musinfo.Instance.TSC_Khz / 1000));
   end Clock;

   procedure Set_Timeout (C : in out Client_Session;
                          D :        Duration)
   is
      use type Standard.Interfaces.Unsigned_64;
      function To_Nanosecs is new Ada.Unchecked_Conversion (Duration, Standard.Interfaces.Unsigned_64);
      Start : constant Interfaces.Unsigned_64 := Musinfo.Instance.TSC_Schedule_Start;
   begin
      Reg.Registry (C.Index).Next_Timeout := Start + (Musinfo.Instance.TSC_Khz / 1000) * (To_Nanosecs (D) / 1000);
      Reg.Registry (C.Index).Timeout_Set  := True;
   end Set_Timeout;

   procedure Check_Event (I : CIM.Session_Index)
   is
      use type Standard.Interfaces.Unsigned_64;
      Start : constant Interfaces.Unsigned_64 := Musinfo.Instance.TSC_Schedule_Start;
   begin
      if
         Reg.Registry (I).Timeout_Set
         and then Reg.Registry (I).Next_Timeout < Start
      then
         Reg.Registry (I).Timeout_Set := False;
         Event;
      end if;
   end Check_Event;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      if not Initialized (C) then
         return;
      end if;
      Reg.Registry (C.Index) := Reg.Session_Entry'(Kind => CIM.None);
      C.Index := CIM.Invalid_Index;
   end Finalize;

end Componolit.Gneiss.Timer.Client;
