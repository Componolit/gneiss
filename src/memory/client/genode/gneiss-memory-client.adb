
with System;

package body Gneiss.Memory.Client with
   SPARK_Mode
is

   function Event_Address return System.Address;

   procedure Genode_Initialize (Session : in out Client_Session;
                                Cap     :        Capability;
                                Label   :        String;
                                Size    :        Long_Integer;
                                Ev      :        System.Address) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client10initializeEPNS_10CapabilityEPKcxPFvPS0_E";

   procedure Genode_Finalize (Session : in out Client_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client8finalizeEv";

   function Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Initialize_Event'Address;
   end Event_Address;

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Size    :        Long_Integer;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
   begin
      if Status (Session) = Initialized or else Size < 0 then
         return;
      end if;
      Genode_Initialize (Session, Cap, Label & ASCII.NUL, Size, Event_Address);
      if Session.Session /= System.Null_Address and then Session.Addr /= System.Null_Address then
         Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
      end if;
   end Initialize;

   procedure Modify (Session : in out Client_Session)
   is
      Buf : Buffer (Buffer_Index'First ..
                    Buffer_Index'Val (Buffer_Index'Pos (Buffer_Index'First)
                                      + Long_Integer'Pos (Session.Size) - 1)) with
         Import,
         Address => Session.Addr;
   begin
      Modify (Session, Buf);
   end Modify;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      Genode_Finalize (Session);
      Session.Index := Session_Index_Option'(Valid => False);
   end Finalize;

end Gneiss.Memory.Client;
