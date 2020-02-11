
with System;
with Genode;

package body Gneiss.Memory.Dispatcher with
   SPARK_Mode
is
   use type System.Address;

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Genode.Session_Label;
                              Label   :        Genode.Session_Label);

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
                                        Server_S : in out Server_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss17Memory_Dispatcher18session_initializeE"
                       & "PNS_28Memory_Dispatcher_CapabilityEPNS_13Memory_ServerE";

   procedure Genode_Register (Session : in out Dispatcher_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss17Memory_Dispatcher16register_serviceEv";

   procedure Genode_Accept (Session  : in out Dispatcher_Session;
                            Server_S : in out Server_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss17Memory_Dispatcher6acceptEPNS_13Memory_ServerE";

   procedure Genode_Server_Finalize (Session : in out Server_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Server8finalizeEv";

   function To_Ada (S : String) return String;

   function To_Ada (S : String) return String
   is
      Last : Natural := 0;
   begin
      for I in S'Range loop
         exit when S (I) = ASCII.NUL;
         Last := I;
      end loop;
      return S (S'First .. Last);
   end To_Ada;

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Genode.Session_Label;
                              Label   :        Genode.Session_Label)
   is
   begin
      Dispatch (Session, Cap, To_Ada (Name), To_Ada (Label));
   end Genode_Dispatch;

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
   begin
      Genode_Initialize (Session, Cap, Dispatch_Address);
      if
         Session.Root /= System.Null_Address
         and then Session.Dispatch /= System.Null_Address
         and then Session.Env /= System.Null_Address
      then
         Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
      end if;
   end Initialize;

   procedure Register (Session : in out Dispatcher_Session)
   is
   begin
      Genode_Register (Session);
   end Register;

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean is
      (Cap.Session = System.Null_Address);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Idx      :        Session_Index := 1)
   is
   begin
      Genode_Session_Initialize (Session, Cap, Server_S);
      Server_S.Index := Session_Index_Option'(Valid => True, Value => Idx);
      if not Initialized (Session) then
         return;
      end if;
      Server_Instance.Initialize (Server_S);
      if not Server_Instance.Ready (Server_S) then
         Server_S.Index := Session_Index_Option'(Valid => False);
         return;
      end if;
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
      pragma Unreferenced (Session);
   begin
      if Initialized (Server_S) and then Cap.Session = Server_S.Component then
         Server_Instance.Finalize (Server_S);
         Genode_Server_Finalize (Server_S);
      end if;
   end Session_Cleanup;

end Gneiss.Memory.Dispatcher;
