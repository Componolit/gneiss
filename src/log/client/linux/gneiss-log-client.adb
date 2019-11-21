
with Gneiss.Message.Writer;

package body Gneiss.Log.Client
is

   package Writer is new Gneiss.Message.Writer
      (Internal.Log.Unsigned_Character,
       Positive,
       Internal.Log.Message_String,
       Internal.Log.Message_Size);

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (C              : in out Client_Session;
                         Cap            :        Gneiss.Types.Capability;
                         Label          :        String)
   is
   begin
      if Initialized (C) then
         return;
      end if;
      Writer.Initialize (C.Session, Cap, Label);
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (C : in out Client_Session)
   is
   begin
      if not Initialized (C) then
         return;
      end if;
      Writer.Finalize (C.Session);
   end Finalize;

   procedure Concatenate (C : in out Client_Session;
                          S :        String);

   procedure Concatenate (C : in out Client_Session;
                          S :        String)
   is
   begin
      for O of S loop
         if C.Cursor = C.Buffer'Last then
            Flush (C);
         end if;
         C.Buffer (C.Cursor) := Internal.Log.Unsigned_Character (Character'Pos (O));
         C.Cursor            := C.Cursor + 1;
      end loop;
   end Concatenate;

   ----------
   -- Info --
   ----------

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
   begin
      Concatenate (C, "Info: " & Msg);
      if Newline then
         Flush (C);
      end if;
   end Info;

   -------------
   -- Warning --
   -------------

   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
   begin
      Concatenate (C, "Warning: " & Msg);
      if Newline then
         Flush (C);
      end if;
   end Warning;

   -----------
   -- Error --
   -----------

   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
   begin
      Concatenate (C, "Error: " & Msg);
      if Newline then
         Flush (C);
      end if;
   end Error;

   -----------
   -- Flush --
   -----------

   procedure Flush (C : in out Client_Session)
   is
   begin
      Writer.Write (C.Session, C.Buffer);
      C.Cursor := C.Buffer'First;
      C.Buffer := (others => 0);
   end Flush;

end Gneiss.Log.Client;
