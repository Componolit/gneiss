
with System;

package body Gneiss.Rom.Client with
   SPARK_Mode
is

   procedure Genode_Initialize (Session : in out Client_Session;
                                Cap     :        Gneiss.Capability;
                                Label   :        String) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss10Rom_Client10initializeEPNS_10CapabilityEPKc";

   procedure Genode_Update (Session : in out Client_Session;
                            Ctx     : in out Context) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss10Rom_Client6updateEPv";

   procedure Genode_Finalize (Session : in out Client_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss10Rom_Client8finalizeEv";

   procedure Genode_Read (Session : in out Client_Session;
                          Ptr     :        System.Address;
                          Size    :        Integer;
                          Ctx     : in out Context);

   function Modify_Address return System.Address;

   function Modify_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Genode_Read'Address;
   end Modify_Address;

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Gneiss.Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
   begin
      if Initialized (Session) then
         return;
      end if;
      Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
      Session.Read  := Modify_Address;
      Genode_Initialize (Session, Cap, Label & ASCII.NUL);
      if Session.Rom = System.Null_Address then
         Session.Index := Session_Index_Option'(Valid => False);
         Session.Read  := System.Null_Address;
      end if;
   end Initialize;

   procedure Update (Session : in out Client_Session;
                     Ctx     : in out Context)
   is
   begin
      Genode_Update (Session, Ctx);
   end Update;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if not Initialized (Session) then
         return;
      end if;
      Genode_Finalize (Session);
      Session.Index := Session_Index_Option'(Valid => False);
      Session.Read  := System.Null_Address;
      Session.Rom   := System.Null_Address;
   end Finalize;

   procedure Genode_Read (Session : in out Client_Session;
                          Ptr     :        System.Address;
                          Size    :        Integer;
                          Ctx     : in out Context)
   is
      Buf : constant Buffer
         (Buffer_Index'First
          .. Buffer_Index'Val (Buffer_Index'Pos (Buffer_Index'First) + Integer'Pos (Size) - 1)) with
            Import,
            Address => Ptr;
   begin
      Read (Session, Buf, Ctx);
   end Genode_Read;

end Gneiss.Rom.Client;
