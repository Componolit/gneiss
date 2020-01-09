
with System;

package body Gneiss.Log.Dispatcher with
   SPARK_Mode
is

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        System.Address;
                              Label   :        System.Address);

   function Get_Dispatch_Address return System.Address;

   procedure Genode_Initialize (Session : in out Dispatcher_Session;
                                Cap     :        Capability;
                                Idx     :        Session_Index;
                                Disp    :        System.Address) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher10initializeEPNS_10"
                       & "CapabilityEiMS0_FvPNS_25Log_Dispatcher_CapabilityEPKcS6_E";

   procedure Genode_Register (Session : in out Dispatcher_Session) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher16register_serviceEv";

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        System.Address;
                              Label   :        System.Address)
   is
   begin
      null;
   end Genode_Dispatch;

   function Get_Dispatch_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Genode_Dispatch'Address;
   end Get_Dispatch_Address;

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 0)
   is
   begin
      Genode_Initialize (Session, Cap, Idx, Get_Dispatch_Address);
   end Initialize;

   procedure Register (Session : in out Dispatcher_Session)
   is
   begin
      Genode_Register (Session);
   end Register;

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean is
      (False);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Idx      :        Session_Index := 0)
   is
   begin
      null;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session)
   is
   begin
      null;
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session)
   is
   begin
      null;
   end Session_Cleanup;

end Gneiss.Log.Dispatcher;
