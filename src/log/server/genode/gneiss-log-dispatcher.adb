
with Genode;
with System;

package body Gneiss.Log.Dispatcher with
   SPARK_Mode
is
   use type System.Address;

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Genode.Session_Label;
                              Label   :        Genode.Session_Label);

   function Get_Dispatch_Address return System.Address;

   procedure Genode_Initialize (Session : in out Dispatcher_Session;
                                Cap     :        Capability;
                                Disp    :        System.Address) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher10initializeE"
                       & "PNS_10CapabilityEPFvPS0_PNS_25Log_Dispatcher_CapabilityEPKcS7_E";

   procedure Genode_Register (Session : in out Dispatcher_Session) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher16register_serviceEv";

   procedure Genode_Accept (Session  : in out Dispatcher_Session;
                            Server_S : in out Server_Session) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher6acceptEPNS_10Log_ServerE";

   procedure Genode_Initialize_Session (Session  : in out Dispatcher_Session;
                                        Cap      :        Dispatcher_Capability;
                                        Server_S : in out Server_Session;
                                        Write    :        System.Address) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher18session_initializeE"
                       & "PNS_25Log_Dispatcher_CapabilityEPNS_10Log_ServerEPFvS4_PKciPiE";

   procedure Genode_Cleanup (Session  : in out Dispatcher_Session;
                             Server_S : in out Server_Session) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher7cleanupEPNS_10Log_ServerE";

   procedure Genode_Write (Session : in out Server_Session;
                           Data    :        System.Address;
                           Len     :        Integer;
                           Done    :    out Integer);

   function Get_Write_Address return System.Address;

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Genode.Session_Label;
                              Label   :        Genode.Session_Label)
   is
      function Last (S : Genode.Session_Label) return Natural;
      function Last (S : Genode.Session_Label) return Natural
      is
         L : Natural := S'Last;
      begin
         for I in S'Range loop
            L := I - 1;
            exit when S (I) = ASCII.NUL;
         end loop;
         return L;
      end Last;
   begin
      Dispatch (Session, Cap, Name (1 .. Last (Name)), Label (1 .. Last (Label)));
   end Genode_Dispatch;

   procedure Genode_Write (Session : in out Server_Session;
                           Data    :        System.Address;
                           Len     :        Integer;
                           Done    :    out Integer)
   is
      Str : String (1 .. Len) with
         Import,
         Address => Data;
   begin
      Server_Instance.Write (Session, Str);
      Done := Len;
   end Genode_Write;

   function Get_Dispatch_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Genode_Dispatch'Address;
   end Get_Dispatch_Address;

   function Get_Write_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Genode_Write'Address;
   end Get_Write_Address;

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1)
   is
   begin
      Genode_Initialize (Session, Cap, Get_Dispatch_Address);
      if Initialized (Session) then
         Session.Index := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
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
   begin
      Server_S.Index := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
      Genode_Initialize_Session (Session, Cap, Server_S, Get_Write_Address);
      if not Initialized (Server_S) then
         Server_S.Index := Gneiss.Session_Index_Option'(Valid => False);
      end if;
      Server_Instance.Initialize (Server_S, Ctx);
      if not Server_Instance.Ready (Server_S, Ctx) then
         Genode_Cleanup (Session, Server_S);
         Server_S.Index     := Gneiss.Session_Index_Option'(Valid => False);
         Server_S.Component := System.Null_Address;
         Server_S.Write     := System.Null_Address;
         return;
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
   begin
      if not Initialized (Server_S) or else Cap.Session /= Server_S.Component then
         return;
      end if;
      Server_Instance.Finalize (Server_S, Ctx);
      Genode_Cleanup (Session, Server_S);
      Server_S.Index     := Gneiss.Session_Index_Option'(Valid => False);
      Server_S.Component := System.Null_Address;
      Server_S.Write     := System.Null_Address;
   end Session_Cleanup;

end Gneiss.Log.Dispatcher;
