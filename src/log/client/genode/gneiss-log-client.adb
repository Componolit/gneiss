
with System;
with Basalt.Slicer;

package body Gneiss.Log.Client with
   SPARK_Mode
is

   Maximum_Message_Length : constant Integer := 216;

   package String_Slicer is new Basalt.Slicer (Positive);

   procedure Genode_Initialize (Session : in out Client_Session;
                                Cap     :        Capability;
                                Label   :        String) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss10Log_Client10initializeEPNS_10CapabilityEPKc";

   procedure Genode_Write (Session : in out Client_Session;
                           Msg     :        String) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss10Log_Client5writeEPKc";

   procedure Genode_Finalize (Session : in out Client_Session) with
      Import,
      Convention    => C,
      External_Name => "_ZN6Gneiss10Log_Client8finalizeEv";

   procedure Write (C : in out Client_Session;
                    M :        String);

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String)
   is
   begin
      if Initialized (Session) then
         return;
      end if;
      Genode_Initialize (Session, Cap, Label & ASCII.NUL);
      Session.Cursor := Session.Buffer'First;
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if not Initialized (Session) then
         return;
      end if;
      Genode_Finalize (Session);
      Session.Session := System.Null_Address;
   end Finalize;

   Blue       : constant String    := Character'Val (8#33#) & "[34m";
   Red        : constant String    := Character'Val (8#33#) & "[31m";
   Reset      : constant String    := Character'Val (8#33#) & "[0m";

   procedure Info (Session : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
   begin
      Print (Session, Msg);
      if Newline then
         Print (Session, (1 => ASCII.LF));
         Flush (Session);
      end if;
   end Info;

   procedure Warning (Session : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
   begin
      Print (Session, Blue);
      Print (Session, "Warning: ");
      Print (Session, Msg);
      Print (Session, Reset);
      if Newline then
         Print (Session, (1 => ASCII.LF));
         Flush (Session);
      end if;
   end Warning;

   procedure Error (Session : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
   begin
      Print (Session, Red);
      Print (Session, "Error: ");
      Print (Session, Msg);
      Print (Session, Reset);
      if Newline then
         Print (Session, (1 => ASCII.LF));
         Flush (Session);
      end if;
   end Error;

   procedure Flush (Session : in out Client_Session)
   is
   begin
      if Session.Cursor > Session.Buffer'First then
         Write (Session, Session.Buffer (Session.Buffer'First .. Session.Cursor - 1));
      end if;
      Session.Cursor := Session.Buffer'First;
   end Flush;

   procedure Print (Session : in out Client_Session;
                    Msg     :        String)
   is
   begin
      if Msg'Length = 0 then
         return;
      end if;
      if Msg'Length > Session.Buffer'Last - Session.Cursor then
         Flush (Session);
         Write (Session, Msg);
      else
         Session.Buffer (Session.Cursor .. Session.Cursor + Msg'Length - 1) := Msg;
         Session.Cursor := Session.Cursor + Msg'Length;
         pragma Assert (Session.Cursor in Session.Buffer'Range);
      end if;
   end Print;

   procedure Write (C : in out Client_Session;
                    M :        String)
   is
      Slicer : String_Slicer.Context := String_Slicer.Create (M'First, M'Last, Maximum_Message_Length);
      Slice  : String_Slicer.Slice;
   begin
      loop
         pragma Loop_Invariant (Initialized (C));
         pragma Loop_Invariant (String_Slicer.Get_Range (Slicer).First = M'First);
         pragma Loop_Invariant (String_Slicer.Get_Range (Slicer).Last = M'Last);
         Slice := String_Slicer.Get_Slice (Slicer);
         Genode_Write (C, M (Slice.First .. Slice.Last) & ASCII.NUL);
         exit when not String_Slicer.Has_Next (Slicer);
         String_Slicer.Next (Slicer);
      end loop;
   end Write;

end Gneiss.Log.Client;
