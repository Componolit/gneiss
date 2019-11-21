
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

   procedure Buffer (C : in out Client_Session;
                     M :        String) with
      Pre  => Initialized (C),
      Post => Initialized (C);

   procedure Initialize (C              : in out Client_Session;
                         Cap            :        Gneiss.Types.Capability;
                         Label          :        String) with
      SPARK_Mode => Off
   is
      C_Label : String := Label & Character'Val (0);
   begin
      if Initialized (C) then
         return;
      end if;
      Cxx.Log.Client.Initialize (C.Instance,
                                 Cap,
                                 C_Label'Address);
      C.Cursor := C.Buffer'First;
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      if not Initialized (C) then
         return;
      end if;
      Cxx.Log.Client.Finalize (C.Instance);
   end Finalize;

   Blue       : constant String    := Character'Val (8#33#) & "[34m";
   Red        : constant String    := Character'Val (8#33#) & "[31m";
   Reset      : constant String    := Character'Val (8#33#) & "[0m";

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
   begin
      Buffer (C, Msg);
      if Newline then
         Buffer (C, (1 => ASCII.LF));
         Flush (C);
      end if;
   end Info;

   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
   begin
      Buffer (C, Blue);
      Buffer (C, "Warning: ");
      Buffer (C, Msg);
      Buffer (C, Reset);
      if Newline then
         Buffer (C, (1 => ASCII.LF));
         Flush (C);
      end if;
   end Warning;

   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
   begin
      Buffer (C, Red);
      Buffer (C, "Error: ");
      Buffer (C, Msg);
      Buffer (C, Reset);
      if Newline then
         Buffer (C, (1 => ASCII.LF));
         Flush (C);
      end if;
   end Error;

   procedure Flush (C : in out Client_Session)
   is
   begin
      if C.Cursor > C.Buffer'First then
         Write (C.Instance, C.Buffer (C.Buffer'First .. C.Cursor - 1));
      end if;
      C.Cursor := C.Buffer'First;
   end Flush;

   procedure Buffer (C : in out Client_Session;
                     M :        String)
   is
   begin
      if M'Length = 0 then
         return;
      end if;
      if M'Length > C.Buffer'Last - C.Cursor then
         Flush (C);
         Write (C.Instance, M);
      else
         C.Buffer (C.Cursor .. C.Cursor + M'Length - 1) := M;
         C.Cursor := C.Cursor + M'Length;
         pragma Assert (C.Cursor in C.Buffer'Range);
      end if;
   end Buffer;

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
