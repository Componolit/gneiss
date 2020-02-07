
with System;
with Genode;

package body Gneiss.Memory.Dispatcher with
   SPARK_Mode
is

   procedure Genode_Modify (Session : in out Server_Session;
                            Ptr     :        System.Address;
                            Size    :        Integer);

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Genode.Session_Label;
                              Label   :        Genode.Session_Label);

   function Modify_Address return System.Address;

   function Dispatch_Address return System.Address;

   procedure Genode_Initialize (Session : in out Dispatcher_Session;
                                Cap     :        Capability;
                                Disp    :        System.Address) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss17Memory_Dispatcher10initializeE"
                       & "PNS_10CapabilityEPFvPS0_PNS_28Memory_Dispatcher_CapabilityEPKcS7_E";

   procedure Genode_Session_Initialize (Session  : in out Dispatcher_Session;
                                        Cap      :        Dispatcher_Capability;
                                        Server_S : in out Server_Session;
                                        Mod_Func :        System.Address) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss17Memory_Dispatcher18session_initializeE"
                       & "PNS_28Memory_Dispatcher_CapabilityEPNS_13Memory_ServerEPFvS4_PviE";

   procedure Genode_Register (Session : in out Dispatcher_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss17Memory_Dispatcher16register_serviceEv";

   procedure Genode_Accept (Session  : in out Dispatcher_Session;
                            Server_S : in out Server_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss17Memory_Dispatcher6acceptEPNS_13Memory_ServerE";

   procedure Genode_Cleanup (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss17Memory_Dispatcher7cleanupE"
                       & "PNS_28Memory_Dispatcher_CapabilityEPNS_13Memory_ServerE";

   procedure Genode_Modify (Session : in out Server_Session;
                            Ptr     :        System.Address;
                            Size    :        Integer)
   is
   begin
      null;
   end Genode_Modify;

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Genode.Session_Label;
                              Label   :        Genode.Session_Label)
   is
   begin
      null;
   end Genode_Dispatch;

   function Modify_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Genode_Modify'Address;
   end Modify_Address;

   function Dispatch_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Genode_Dispatch'Address;
   end Dispatch_Address;


   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1)
   is
      pragma Unreferenced (Idx);
   begin
      Genode_Initialize (Session, Cap, Dispatch_Address);
      --  FIXME: initialization check and index
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
                                 Idx      :        Session_Index := 1)
   is
      pragma Unreferenced (Idx);
   begin
      Genode_Session_Initialize (Session, Cap, Server_S, Modify_Address);
      --  FIXME: initialization check and index
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session)
   is
      pragma Unreferenced (Cap);
   begin
      Genode_Accept (Session, Server_S);
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session)
   is
   begin
      Genode_Cleanup (Session, Cap, Server_S);
   end Session_Cleanup;

end Gneiss.Memory.Dispatcher;
