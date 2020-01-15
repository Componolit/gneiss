
with System;

package body Gneiss.Log.Dispatcher with
   SPARK_Mode
is
   use type System.Address;

   subtype Session_Label is String (1 .. 160);

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Session_Label;
                              Label   :        Session_Label);

   function Get_Dispatch_Address return System.Address;

   procedure Genode_Initialize (Session : in out Dispatcher_Session;
                                Cap     :        Capability;
                                Idx     :        Session_Index;
                                Disp    :        System.Address) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher10initializeE"
                       & "PNS_10CapabilityEiPFvPS0_PNS_25Log_Dispatcher_CapabilityEPKcS7_E";

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
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session) with
      Import,
      Convention    => CPP,
      External_Name => "_ZN6Gneiss14Log_Dispatcher7cleanupEPNS_25Log_Dispatcher_CapabilityEPNS_10Log_ServerE";

   procedure Genode_Write (Session : in out Server_Session;
                           Data    :        System.Address;
                           Len     :        Integer;
                           Done    :    out Integer);

   function Get_Write_Address return System.Address;

   procedure Genode_Dispatch (Session : in out Dispatcher_Session;
                              Cap     :        Dispatcher_Capability;
                              Name    :        Session_Label;
                              Label   :        Session_Label)
   is
      function Last (S : Session_Label) return Natural;
      function Last (S : Session_Label) return Natural
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
      Genode_Initialize (Session, Cap, Idx, Get_Dispatch_Address);
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
      Server_S.Index := Idx;
      Server_Instance.Initialize (Server_S);
      if not Server_Instance.Ready (Server_S) then
         Server_S.Index := 0;
         return;
      end if;
      Genode_Initialize_Session (Session, Cap, Server_S, Get_Write_Address);
      if not Initialized (Server_S) then
         Server_Instance.Finalize (Server_S);
         Server_S.Index := 0;
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
   begin
      Genode_Cleanup (Session, Cap, Server_S);
   end Session_Cleanup;

end Gneiss.Log.Dispatcher;
