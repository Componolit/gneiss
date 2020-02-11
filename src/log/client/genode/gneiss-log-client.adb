
with Cxx;
with Cxx.Log.Client;
with Basalt.Slicer;

package body Gneiss.Log.Client with
   SPARK_Mode
is
   use type Cxx.Bool;

   package String_Slicer is new Basalt.Slicer (Positive);

   function Initialized (C : Cxx.Log.Client.Class) return Boolean is
      (Cxx.Log.Client.Initialized (C) = Cxx.Bool'Val (1));

   procedure Write (C : Cxx.Log.Client.Class;
                    M : String) with
      Pre => Initialized (C)
             and then M'Length > 0;

   procedure C_Write (C : Cxx.Log.Client.Class;
                      M : String) with
      Pre => Initialized (C);

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1) with
      SPARK_Mode => Off
   is
      C_Label : String := Label & Character'Val (0);
   begin
      if Status (Session) = Initialized then
         return;
      end if;
      Cxx.Log.Client.Initialize (Session.Instance,
                                 Cap,
                                 C_Label'Address,
                                 Initialize_Event'Address);
      Session.Cursor := Session.Buffer'First;
      Session.Index  := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if Status (Session) = Uninitialized then
         return;
      end if;
      Session.Index := Gneiss.Session_Index_Option'(Valid => False);
      Cxx.Log.Client.Finalize (Session.Instance);
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
         Write (Session.Instance, Session.Buffer (Session.Buffer'First .. Session.Cursor - 1));
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
         Write (Session.Instance, Msg);
      else
         Session.Buffer (Session.Cursor .. Session.Cursor + Msg'Length - 1) := Msg;
         Session.Cursor := Session.Cursor + Msg'Length;
         pragma Assert (Session.Cursor in Session.Buffer'Range);
      end if;
   end Print;

   procedure Write (C : Cxx.Log.Client.Class;
                    M : String)
   is
      Len    : constant Positive     := Positive (Cxx.Log.Client.Maximum_Message_Length (C));
      Slicer : String_Slicer.Context := String_Slicer.Create (M'First, M'Last, Len);
      Slice  : String_Slicer.Slice;
   begin
      loop
         pragma Loop_Invariant (Initialized (C));
         pragma Loop_Invariant (String_Slicer.Get_Range (Slicer).First = M'First);
         pragma Loop_Invariant (String_Slicer.Get_Range (Slicer).Last = M'Last);
         Slice := String_Slicer.Get_Slice (Slicer);
         C_Write (C, M (Slice.First .. Slice.Last));
         exit when not String_Slicer.Has_Next (Slicer);
         String_Slicer.Next (Slicer);
      end loop;
   end Write;

   procedure C_Write (C : Cxx.Log.Client.Class;
                      M : String) with
      SPARK_Mode => Off
   is
      C_Msg : String := M & ASCII.NUL;
   begin
      Cxx.Log.Client.Write (C, C_Msg'Address);
   end C_Write;

end Gneiss.Log.Client;
