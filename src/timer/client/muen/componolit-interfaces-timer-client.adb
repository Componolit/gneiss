
with Ada.Unchecked_Conversion;
with Interfaces;
with Componolit.Interfaces.Muen;
with Musinfo;
with Musinfo.Instance;

package body Componolit.Interfaces.Timer.Client with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;

   function Create return Client_Session
   is
   begin
      return Client_Session (CIM.Invalid_Index);
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
      use type CIM.Session_Index;
      use type CIM.Session_Type;
      Index : constant CIM.Session_Index := CIM.Session_Index (C);
   begin
      return Index /= CIM.Invalid_Index and then CIM.Session_Registry (Index).Session = CIM.Timer;
   end Initialized;

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Interfaces.Types.Capability)
   is
      pragma Unreferenced (Cap);
      use type CIM.Session_Type;
   begin
      for I in CIM.Session_Registry'Range loop
         if CIM.Session_Registry (I).Session = CIM.None then
            C := Client_Session (I);
            CIM.Session_Registry (I) := CIM.Session_Element'(Session => CIM.Timer);
         end if;
      end loop;
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
      CIM.Session_Registry (CIM.Session_Index (C)) := CIM.Session_Element'(Session => CIM.None);
      C := Client_Session (CIM.Invalid_Index);
   end Finalize;

end Componolit.Interfaces.Timer.Client;
