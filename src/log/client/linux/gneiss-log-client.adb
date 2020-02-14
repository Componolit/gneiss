
with Gneiss.Protocol;
with Gneiss_Syscall;
with Gneiss_Platform;
with Gneiss_Internal.Message_Syscall;
with RFLX.Session;

package body Gneiss.Log.Client
is

   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   package Proto is new Gneiss.Protocol (Character, RFLX_String);

   procedure Init (Session  : in out Client_Session;
                   Label    :        String;
                   Success  :        Boolean;
                   Filedesc :        Integer);
   function Init_Cap is new Gneiss_Platform.Create_Initializer_Cap (Client_Session, Init);

   procedure Prefix_Message (Session : in out Client_Session;
                             Prefix  :        String;
                             Msg     :        String;
                             Newline :        Boolean);

   function Create_Request (Label : RFLX_String) return Proto.Message is
      (Proto.Message'(Length      => Label'Length,
                      Action      => RFLX.Session.Request,
                      Kind        => RFLX.Session.Log,
                      Name_Length => 0,
                      Payload     => Label));

   procedure Init (Session  : in out Client_Session;
                   Label    :        String;
                   Success  :        Boolean;
                   Filedesc :        Integer)
   is
   begin
      if Label /= Session.Label.Value (Session.Label.Value'First .. Session.Label.Last) then
         return;
      end if;
      if Success then
         Session.File_Descriptor := Filedesc;
      end if;
      Session.Pending := False;
      Initialize_Event (Session);
   end Init;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
      Succ : Boolean;
      C_Label : RFLX_String (1 .. 255);
   begin
      if
         Status (Session) in Initialized | Pending
         or else Label'Length > 255
      then
         return;
      end if;
      Session.Index := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
      Session.Label.Last := Session.Label.Value'First + Label'Length - 1;
      Session.Label.Value
         (Session.Label.Value'First
          .. Session.Label.Value'First + Label'Length - 1) := Label;
      for I in C_Label'Range loop
         C_Label (I) := Session.Label.Value (Positive (I));
      end loop;
      Session.Pending := True;
      Gneiss_Platform.Call (Cap.Register_Initializer, Init_Cap (Session),
                            RFLX.Session.Log, Succ);
      if Succ then
         Proto.Send_Message
            (Cap.Broker_Fd,
             Create_Request (C_Label (C_Label'First .. RFLX.Session.Length_Type (Session.Label.Last))));
      else
         Session.Index := Session_Index_Option'(Valid => False);
         Init (Session, Label, False, -1);
      end if;
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      Gneiss_Syscall.Close (Session.File_Descriptor);
      Session.Label.Last := 0;
      Session.Index      := Session_Index_Option'(Valid => False);
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
