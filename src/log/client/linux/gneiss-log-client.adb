
with Gneiss.Message.Generic_Client;
with RFLX.Session;

package body Gneiss.Log.Client
is

   package Message_Client is new Gneiss_Internal.Log.Message_Log.Generic_Client
      (Event, RFLX.Session.Log);

   procedure Prefix_Message (Session : in out Client_Session;
                             Prefix  :        String;
                             Msg     :        String;
                             Newline :        Boolean);

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 0)
   is
   begin
      Message_Client.Initialize (Session.Message, Cap, Label, Idx);
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      Message_Client.Finalize (Session.Message);
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
         if C = ASCII.LF and then Session.Cursor < Session.Buffer'Last then
            Session.Buffer (Session.Cursor + 1) := ASCII.NUL;
            Flush (Session);
         elsif Session.Cursor = Session.Buffer'Last then
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
      Message_Client.Write (Session.Message, Session.Buffer);
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
