
with System;
with Genode;

package body Gneiss.Message.Dispatcher with
   SPARK_Mode
is
   use type System.Address;

   function Dispatch_Address return System.Address;
   function Avail_Address return System.Address;
   function Recv_Address return System.Address;
   function Get_Address return System.Address;

   procedure Genode_Initialize (Session : in out Dispatcher_Session;
                                Cap     :        Capability) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss18Message_Dispatcher10initializeEPNS_10CapabilityE";

   procedure Genode_Register (Session : in out Dispatcher_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss18Message_Dispatcher16register_serviceEv";

   procedure Genode_Accept (Session  : in out Dispatcher_Session;
                            Server_S : in out Server_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss18Message_Dispatcher6acceptEPNS_14Message_ServerE";

   procedure Genode_Finalize (Session : in out Server_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss14Message_Server8finalizeEv";

   procedure Genode_Initialize (Session  : in out Dispatcher_Session;
                                Server_S : in out Server_Session;
                                Avail    :        System.Address;
                                Recv     :        System.Address;
                                Get      :        System.Address) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss18Message_Dispatcher18session_initializeE"
                       & "PNS_14Message_ServerEPFiS2_EPFvS2_PKNS_15Message_Session14Message_BufferEEPFvS2_PS6_E";

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Genode.Session_Label;
                              Label   :        Genode.Session_Label);

   function Avail (Session : Server_Session) return Integer;

   procedure Get (Session : in out Server_Session;
                  Data    :    out Message_Buffer);

   function Dispatch_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Genode_Dispatch'Address;
   end Dispatch_Address;

   function Avail_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Avail'Address;
   end Avail_Address;

   function Recv_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Server_Instance.Receive'Address;
   end Recv_Address;

   function Get_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Get'Address;
   end Get_Address;

   function Avail (Session : Server_Session) return Integer
   is
   begin
      return Integer'Val (Boolean'Pos (Internal.Queue.Count (Session.Cache) > 0));
   end Avail;

   procedure Get (Session : in out Server_Session;
                  Data    :    out Message_Buffer)
   is
   begin
      Internal.Queue.Pop (Session.Cache, Data);
   end Get;

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Genode.Session_Label;
                              Label   :        Genode.Session_Label)
   is
   begin
      Dispatch (Session, Cap, Genode.To_String (Name), Genode.To_String (Label));
   end Genode_Dispatch;

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1)
   is
   begin
      Session.Index    := Session_Index_Option'(Valid => True, Value => Idx);
      Session.Dispatch := Dispatch_Address;
      Genode_Initialize (Session, Cap);
      if
         Session.Env = System.Null_Address
         or else Session.Dispatch = System.Null_Address
      then
         Session.Index := Session_Index_Option'(Valid => False);
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
                                 Ctx      : in out Server_Instance.Context;
                                 Idx      :        Session_Index := 1)
   is
      pragma Unreferenced (Cap);
   begin
      Genode_Initialize (Session, Server_S, Avail_Address, Recv_Address, Get_Address);
      if Server_S.Component /= System.Null_Address then
         Server_S.Index := Session_Index_Option'(Valid => True, Value => Idx);
         Server_Instance.Initialize (Server_S, Ctx);
         if not Server_Instance.Ready (Server_S, Ctx) then
            Genode_Finalize (Server_S);
            Server_S.Index := Session_Index_Option'(Valid => False);
         end if;
      end if;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session;
                             Ctx      :        Server_Instance.Context)
   is
      pragma Unreferenced (Cap);
      pragma Unreferenced (Ctx);
   begin
      Genode_Accept (Session, Server_S);
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session;
                              Ctx      : in out Server_Instance.Context)
   is
      pragma Unreferenced (Session);
   begin
      if Initialized (Server_S) and then Cap.Session = Server_S.Component then
         Server_Instance.Finalize (Server_S, Ctx);
         Genode_Finalize (Server_S);
         Server_S.Index := Session_Index_Option'(Valid => False);
      end if;
   end Session_Cleanup;

end Gneiss.Message.Dispatcher;
