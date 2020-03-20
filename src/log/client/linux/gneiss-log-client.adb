
with Gneiss_Syscall;
with Gneiss_Internal.Message_Syscall;
with Gneiss.Platform_Client;
with RFLX.Session;

package body Gneiss.Log.Client
is

   procedure Prefix_Message (Session : in out Client_Session;
                             Prefix  :        String;
                             Msg     :        String;
                             Newline :        Boolean);

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String)
   is
      Fds : Gneiss_Syscall.Fd_Array (1 .. 1) := (others => -1);
   begin
      if Initialized (Session) or else Label'Length > 255 then
         return;
      end if;
      Platform_Client.Initialize (Cap, RFLX.Session.Log, Fds, Label);
      if Fds (Fds'First) < 0 then
         return;
      end if;
      Session.Label.Last := Session.Label.Value'First + Label'Length - 1;
      Session.Label.Value
         (Session.Label.Value'First
          .. Session.Label.Value'First + Label'Length - 1) := Label;
      Session.File_Descriptor := Fds (Fds'First);
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      Gneiss_Syscall.Close (Session.File_Descriptor);
      Session.Label.Last := 0;
   end Finalize;

   -----------
   -- Print --
   -----------

   procedure Print (Session : in out Client_Session;
                    Msg     :        String)
   is
   begin
      for C of Msg loop
         Session.Cursor := Session.Cursor + 1;
         Session.Buffer (Session.Cursor) := C;
         if
            (C = ASCII.LF and then Session.Cursor < Session.Buffer'Last)
            or else Session.Cursor = Session.Buffer'Last
         then
            Flush (Session);
         end if;
      end loop;
   end Print;

   ----------
   -- Info --
   ----------

   procedure Info (Session : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
   begin
      Prefix_Message (Session, "Info: ", Msg, Newline);
   end Info;

   -------------
   -- Warning --
   -------------

   procedure Warning (Session : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
   begin
      Prefix_Message (Session, "Warning: ", Msg, Newline);
   end Warning;

   -----------
   -- Error --
   -----------

   procedure Error (Session : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
   begin
      Prefix_Message (Session, "Error: ", Msg, Newline);
   end Error;

   -----------
   -- Flush --
   -----------

   procedure Flush (Session : in out Client_Session) with
      SPARK_Mode => Off
   is
   begin
      if Session.Cursor < Session.Buffer'Last then
         Session.Buffer (Session.Cursor + 1) := ASCII.NUL;
      end if;
      Gneiss_Internal.Message_Syscall.Write (Session.File_Descriptor,
                                             Session.Buffer'Address,
                                             Session.Buffer'Length);
      Session.Cursor := 0;
   end Flush;

   procedure Prefix_Message (Session : in out Client_Session;
                             Prefix  :        String;
                             Msg     :        String;
                             Newline :        Boolean)
   is
   begin
      Print (Session, Prefix);
      Print (Session, Msg);
      if Newline then
         Print (Session, String'(1 => ASCII.LF));
      end if;
   end Prefix_Message;

end Gneiss.Log.Client;
