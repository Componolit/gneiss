
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Log.Server;
with Gneiss.Log.Dispatcher;

package body Component with
   SPARK_Mode
is

   type Color is (Red, Orange, Yellow, Green, Cyan, Blue, Magenta);

   type Server_Slot is record
      Ident   : String (1 .. 513)  := (others => ASCII.NUL);
      Last    : Natural            := 0;
      Buffer  : String (1 .. 1024) := (others => ASCII.NUL);
      Cursor  : Natural            := 0;
      Hue     : Color              := Red;
      Ready   : Boolean            := False;
      Flushed : Boolean            := True;
   end record with
      Dynamic_Predicate => Last <= Ident'Last
                           and then Cursor <= Buffer'Last - 4;

   subtype Server_Index is Gneiss.Session_Index range 1 .. 10;
   type Server_Reg is array (Server_Index'Range) of Gneiss.Log.Server_Session;
   type Server_Meta is array (Server_Index'Range) of Server_Slot;

   Color_Red     : constant String := Character'Val (8#33#) & "[31m";
   Color_Orange  : constant String := Character'Val (8#33#) & "[91m";
   Color_Yellow  : constant String := Character'Val (8#33#) & "[33m";
   Color_Green   : constant String := Character'Val (8#33#) & "[32m";
   Color_Cyan    : constant String := Character'Val (8#33#) & "[36m";
   Color_Blue    : constant String := Character'Val (8#33#) & "[34m";
   Color_Magenta : constant String := Character'Val (8#33#) & "[35m";
   Reset         : constant String := Character'Val (8#33#) & "[0m";

   Dispatcher  : Gneiss.Log.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg;
   Server_Data : Server_Meta;
   Client      : Gneiss.Log.Client_Session;

   function Get_Color (C : Color) return String is
      (case C is
         when Red     => Color_Red,
         when Orange  => Color_Orange,
         when Yellow  => Color_Yellow,
         when Green   => Color_Green,
         when Cyan    => Color_Cyan,
         when Blue    => Color_Blue,
         when Magenta => Color_Magenta);

   function Rainbow (C : Color) return Color is
      (case C is
         when Red     => Orange,
         when Orange  => Yellow,
         when Yellow  => Green,
         when Green   => Cyan,
         when Cyan    => Blue,
         when Blue    => Magenta,
         when Magenta => Red);

   pragma Warnings (Off, """Session"" is not modified");
   procedure Write (Session : in out Gneiss.Log.Server_Session;
                    Data    :        String) with
      Pre  => Gneiss.Log.Initialized (Session),
      Post => Gneiss.Log.Initialized (Session);
   procedure Initialize (Session : in out Gneiss.Log.Server_Session;
                         Context : in out Server_Meta) with
      Pre  => Gneiss.Log.Initialized (Session),
      Post => Gneiss.Log.Initialized (Session);
   procedure Finalize (Session : in out Gneiss.Log.Server_Session;
                       Context : in out Server_Meta) with
      Pre  => Gneiss.Log.Initialized (Session),
      Post => Gneiss.Log.Initialized (Session);
   pragma Warnings (Off, """Session"" is not modified");

   function Ready (Session : Gneiss.Log.Server_Session;
                   Context : Server_Meta) return Boolean;
   procedure Dispatch (Session : in out Gneiss.Log.Dispatcher_Session;
                       Cap     :        Gneiss.Log.Dispatcher_Capability;
                       Name    :        String;
                       Label   :        String) with
      Pre  => Gneiss.Log.Initialized (Session),
      Post => Gneiss.Log.Initialized (Session);

   procedure Put_Color (S : in out Server_Slot;
                        C :        Character) with
      Pre  => Gneiss.Log.Initialized (Client),
      Post => Gneiss.Log.Initialized (Client);

   procedure Put (S : in out Server_Slot;
                  C :        Character) with
      Pre  => Gneiss.Log.Initialized (Client),
      Post => Gneiss.Log.Initialized (Client)
              and then (if S.Cursor'Old = S.Buffer'Last - 4
                        then S.Cursor = 1
                        else S.Cursor = S.Cursor'Old + 1);

   procedure Flush (S : in out Server_Slot) with
      Pre  => Gneiss.Log.Initialized (Client),
      Post => Gneiss.Log.Initialized (Client)
              and then S.Cursor = 0;

   package Log_Server is new Gneiss.Log.Server (Server_Meta, Write, Initialize, Finalize, Ready);
   package Log_Dispatcher is new Gneiss.Log.Dispatcher (Log_Server, Dispatch);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Dispatcher.Initialize (Dispatcher, Cap);
      Gneiss.Log.Client.Initialize (Client, Capability, "lolcat");
      if
         Gneiss.Log.Initialized (Dispatcher)
         and then Gneiss.Log.Initialized (Client)
      then
            Log_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Write (Session : in out Gneiss.Log.Server_Session;
                    Data    :        String)
   is
      use type Gneiss.Session_Index;
      I : constant Gneiss.Session_Index_Option := Gneiss.Log.Index (Session);
   begin
      if
         not Gneiss.Log.Initialized (Client)
         or else I.Value not in Server_Data'Range
      then
         return;
      end if;
      Put (Server_Data (I.Value), '[');
      for J in 1 .. Server_Data (I.Value).Last loop
         pragma Loop_Invariant (I.Value = I.Value'Loop_Entry);
         pragma Loop_Invariant (Gneiss.Log.Initialized (Client));
         pragma Loop_Invariant (I.Value in Server_Data'Range);
         Put (Server_Data (I.Value),
              Server_Data (I.Value).Ident (J));
      end loop;
      Put (Server_Data (I.Value), ']');
      Put (Server_Data (I.Value), ' ');
      for Char of Data loop
         pragma Loop_Invariant (Gneiss.Log.Initialized (Client));
         Put_Color (Server_Data (I.Value), Char);
      end loop;
      Flush (Server_Data (I.Value));
   end;

   procedure Destruct
   is
   begin
      Gneiss.Log.Client.Finalize (Client);
   end Destruct;

   procedure Initialize (Session : in out Gneiss.Log.Server_Session;
                         Context : in out Server_Meta)
   is
      Index : constant Gneiss.Session_Index := Gneiss.Log.Index (Session).Value;
   begin
      if Index in Context'Range then
         Context (Index).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Gneiss.Log.Server_Session;
                       Context : in out Server_Meta)
   is
      Index : constant Gneiss.Session_Index := Gneiss.Log.Index (Session).Value;
   begin
      if Index in Context'Range then
         Context (Gneiss.Log.Index (Session).Value).Ready := False;
      end if;
   end Finalize;

   procedure Dispatch (Session : in out Gneiss.Log.Dispatcher_Session;
                       Cap     :        Gneiss.Log.Dispatcher_Capability;
                       Name    :        String;
                       Label   :        String)
   is
   begin
      if Log_Dispatcher.Valid_Session_Request (Session, Cap) then
         for I in Servers'Range loop
            pragma Loop_Invariant (Gneiss.Log.Initialized (Session));
            if
               not Ready (Servers (I), Server_Data)
               and then not Gneiss.Log.Initialized (Servers (I))
               and then Name'Length <= Server_Data (I).Ident'Last
               and then Label'Length <= Server_Data (I).Ident'Last
               and then Name'Length + Label'Length + 1 <= Server_Data (I).Ident'Last
               and then Name'First < Positive'Last - Server_Data (I).Ident'Last
            then
               Log_Dispatcher.Session_Initialize (Session, Cap, Servers (I), Server_Data, I);
               if Ready (Servers (I), Server_Data) and then Gneiss.Log.Initialized (Servers (I)) then
                  Server_Data (I).Last := Name'Length + Label'Length + 1;
                  Server_Data (I).Ident (Server_Data (I).Ident'First .. Server_Data (I).Last) := Name & ":" & Label;
                  Log_Dispatcher.Session_Accept (Session, Cap, Servers (I), Server_Data);
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Log_Dispatcher.Session_Cleanup (Session, Cap, S, Server_Data);
      end loop;
   end Dispatch;

   function Ready (Session : Gneiss.Log.Server_Session;
                   Context : Server_Meta) return Boolean is
      (if
          Gneiss.Log.Index (Session).Valid
          and then Gneiss.Log.Index (Session).Value in Context'Range
       then Context (Gneiss.Log.Index (Session).Value).Ready
       else False);

   procedure Put_Color (S : in out Server_Slot;
                        C :        Character)
   is
   begin
      if C in ASCII.LF | ASCII.NUL then
         for R of Reset loop
            Put (S, R);
         end loop;
         Put (S, C);
         Flush (S);
      else
         declare
            Clr : constant String := Get_Color (S.Hue);
            --  Separate declaration: non-scalar object declared before loop-invariant is not yet supported
         begin
            for H of Clr loop
               pragma Loop_Invariant (Gneiss.Log.Initialized (Client));
               Put (S, H);
            end loop;
         end;
         Put (S, C);
         S.Hue := Rainbow (S.Hue);
      end if;
   end Put_Color;

   procedure Put (S : in out Server_Slot;
                  C :        Character)
   is
   begin
      if S.Cursor = S.Buffer'Last - 4 then
         Flush (S);
      end if;
      S.Cursor := S.Cursor + 1;
      S.Buffer (S.Cursor) := C;
   end Put;

   procedure Flush (S : in out Server_Slot)
   is
   begin
      S.Buffer (S.Cursor + 1 .. S.Cursor + 4) := Reset;
      Gneiss.Log.Client.Print (Client, S.Buffer (1 .. S.Cursor));
      Gneiss.Log.Client.Flush (Client);
      S.Cursor  := 0;
      S.Flushed := True;
   end Flush;

end Component;
