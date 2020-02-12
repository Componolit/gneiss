
with System;

package body Gneiss.Message.Client with
   SPARK_Mode
is

   function Event_Address return System.Address;
   function Init_Address return System.Address;

   function Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event'Address;
   end Event_Address;

   function Init_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Initialize_Event'Address;
   end Init_Address;

   procedure Genode_Initialize (Session : in out Client_Session;
                                Cap     :        Capability;
                                Label   :        String) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss14Message_Client10initializeEPNS_10CapabilityEPKc";

   procedure Genode_Finalize (Session : in out Client_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss14Message_Client8finalizeEv";

   function Genode_Available (Session : Client_Session) return Integer with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss14Message_Client5availEv";

   procedure Genode_Write (Session : in out Client_Session;
                           Data    :        Message_Buffer) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss14Message_Client5writeEPKNS_15Message_Session14Message_BufferE";

   procedure Genode_Read (Session : in out Client_Session;
                          Data    :    out Message_Buffer) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss14Message_Client4readEPNS_15Message_Session14Message_BufferE";

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
   begin
      Session.Event := Event_Address;
      Session.Init  := Init_Address;
      Genode_Initialize (Session, Cap, Label & ASCII.NUL);
      if Session.Connection /= System.Null_Address then
         Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
      else
         Session.Event := System.Null_Address;
         Session.Init  := System.Null_Address;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if Status (Session) = Uninitialized then
         return;
      end if;
      Genode_Finalize(Session);
      Session.Connection := System.Null_Address;
      Session.Init       := System.Null_Address;
      Session.Event      := System.Null_Address;
      Session.Index      := Session_Index_Option'(Valid => False);
   end Finalize;

   function Available (Session : Client_Session) return Boolean is
      (Genode_Available (Session) = 1);

   procedure Write (Session : in out Client_Session;
                    Content :        Message_Buffer)
   is
   begin
      Genode_Write (Session, Content);
   end Write;

   procedure Read (Session : in out Client_Session;
                   Content :    out Message_Buffer)
   is
   begin
      Genode_Read (Session, Content);
   end Read;

end Gneiss.Message.Client;
