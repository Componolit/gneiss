
with System;

package body Gneiss.Memory.Client with
   SPARK_Mode
is

   procedure Genode_Initialize (Session : in out Client_Session;
                                Cap     :        Capability;
                                Label   :        String;
                                Size    :        Long_Integer) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client10initializeEPNS_10CapabilityEPKcx";

   procedure Genode_Finalize (Session : in out Client_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client8finalizeEv";

   function Address (Session : Client_Session) return System.Address with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client7addressEv";

   function Size (Session : Client_Session) return Long_Integer with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss13Memory_Client4sizeEv";

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Size    :        Long_Integer;
                         Idx     :        Session_Index := 1)
   is
      use type System.Address;
   begin
      if Initialized (Session) or else Size < 0 then
         return;
      end if;
      Genode_Initialize (Session, Cap, Label & ASCII.NUL, Size);
      if Session.Session /= System.Null_Address then
         Session.Index := Session_Index_Option'(Valid => True, Value => Idx);
      end if;
   end Initialize;

   procedure Modify (Session : in out Client_Session)
   is
      Buf : Buffer (Buffer_Index'First ..
                    Buffer_Index'Val (Buffer_Index'Pos (Buffer_Index'First)
                                      + Long_Integer'Pos (Size (Session)) - 1)) with
         Import,
         Address => Address (Session);
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
