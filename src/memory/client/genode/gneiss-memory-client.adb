
with System;

package body Gneiss.Memory.Client with
   SPARK_Mode
is

   procedure Genode_Initialize (Session : in out Client_Session;
                                Cap     :        Gneiss.Capability;
                                Label   :        String) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client10initializeEPNS_10CapabilityEPKc";

   procedure Genode_Update (Session : in out Client_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client6updateEv";

   procedure Genode_Finalize (Session : in out Client_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client8finalizeEv";

   procedure Genode_Modify (Session : in out Client_Session;
                            Ptr     :        System.Address;
                            Size    :        Integer);

   function Event_Address return System.Address;

   function Modify_Address return System.Address;

   function Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event'Address;
   end Event_Address;

   function Modify_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Genode_Modify'Address;
   end Modify_Address;

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Gneiss.Capability;
                         Label   :        String;
                         Mode    :        Access_Mode   := Read_Only;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
   begin
      Session.Index    := Session_Index_Option'(Valid => True, Value => Idx);
      Session.Writable := Mode = Read_Write;
      Session.Event    := Event_Address;
      Session.Modify   := Modify_Address;
      Genode_Initialize (Session, Cap, Label & ASCII.NUL);
      if Session.Rom = System.Null_Address then
         Session.Index  := Session_Index_Option'(Valid => False);
         Session.Event  := System.Null_Address;
         Session.Modify := System.Null_Address;
      end if;
   end Initialize;

   procedure Update (Session : in out Client_Session)
   is
   begin
      Genode_Update (Session);
   end Update;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      Genode_Finalize (Session);
      Session.Index  := Session_Index_Option'(Valid => False);
      Session.Event  := System.Null_Address;
      Session.Modify := System.Null_Address;
      Session.Rom    := System.Null_Address;
   end Finalize;

   procedure Genode_Modify (Session : in out Client_Session;
                            Ptr     :        System.Address;
                            Size    :        Integer)
   is
      Buf : Buffer (Buffer_Index'First
                    .. Buffer_Index'Val (Buffer_Index'Pos (Buffer_Index'First) + Integer'Pos (Size) - 1)) with
         Address => Ptr;
   begin
      if Session.Writable then
         Modify (Session, Buf);
      else
         Read (Session, Buf);
      end if;
   end Genode_Modify;

end Gneiss.Memory.Client;
