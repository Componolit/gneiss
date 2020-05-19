
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Log.Server;
with Gneiss.Log.Dispatcher;

package body Component with
   SPARK_Mode,
   Refined_State => (Component_State => Capability,
                     Platform_State  => (Dispatcher,
                                         Servers,
                                         Server_Data,
                                         Client))
is
   package Log is new Gneiss.Log;

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
   type Server_Reg is array (Server_Index'Range) of Log.Server_Session;
   type Server_Meta is array (Server_Index'Range) of Server_Slot;

   Color_Red     : constant String := Character'Val (8#33#) & "[31m";
   Color_Orange  : constant String := Character'Val (8#33#) & "[91m";
   Color_Yellow  : constant String := Character'Val (8#33#) & "[33m";
   Color_Green   : constant String := Character'Val (8#33#) & "[32m";
   Color_Cyan    : constant String := Character'Val (8#33#) & "[36m";
   Color_Blue    : constant String := Character'Val (8#33#) & "[34m";
   Color_Magenta : constant String := Character'Val (8#33#) & "[35m";
   Reset         : constant String := Character'Val (8#33#) & "[0m";

   Dispatcher  : Log.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg;
   Server_Data : Server_Meta;
   Client      : Log.Client_Session;

   function Get_Color (C : Color) return String is
      (case C is
         when Red     => Color_Red,
         when Orange  => Color_Orange,
         when Yellow  => Color_Yellow,
         when Green   => Color_Green,
         when Cyan    => Color_Cyan,
         when Blue    => Color_Blue,
         when Magenta => Color_Magenta) with
         Global => null;

   function Rainbow (C : Color) return Color is
      (case C is
         when Red     => Orange,
         when Orange  => Yellow,
         when Yellow  => Green,
         when Green   => Cyan,
         when Cyan    => Blue,
         when Blue    => Magenta,
         when Magenta => Red) with
         Global => null;

   pragma Warnings (Off, """Session"" is not modified");

   procedure Write (Session : in out Log.Server_Session;
                    Data    :        String) with
      Pre    => Log.Initialized (Session),
      Post   => Log.Initialized (Session),
      Global => (In_Out => (Server_Data,
                            Client,
                            Gneiss_Internal.Platform_State));

   procedure Initialize (Session : in out Log.Server_Session;
                         Context : in out Server_Meta) with
      Pre    => Log.Initialized (Session),
      Post   => Log.Initialized (Session),
      Global => null;

   procedure Finalize (Session : in out Log.Server_Session;
                       Context : in out Server_Meta) with
      Pre    => Log.Initialized (Session),
      Post   => Log.Initialized (Session),
      Global => null;

   pragma Warnings (Off, """Session"" is not modified");

   function Ready (Session : Log.Server_Session;
                   Context : Server_Meta) return Boolean with
      Global => null;

   procedure Dispatch (Session : in out Log.Dispatcher_Session;
                       Cap     :        Log.Dispatcher_Capability;
                       Name    :        String;
                       Label   :        String) with
      Pre    => Log.Initialized (Session)
                and then Log.Registered (Session),
      Post   => Log.Initialized (Session)
                and then Log.Registered (Session),
      Global => (In_Out => (Server_Data,
                            Servers,
                            Gneiss_Internal.Platform_State));

   procedure Put_Color (S : in out Server_Slot;
                        C :        Character) with
      Pre    => Log.Initialized (Client),
      Post   => Log.Initialized (Client),
      Global => (In_Out => (Client,
                            Gneiss_Internal.Platform_State));

   procedure Put (S : in out Server_Slot;
                  C :        Character) with
      Pre    => Log.Initialized (Client),
      Post   => Log.Initialized (Client)
                and then (if S.Cursor'Old = S.Buffer'Last - 4
                          then S.Cursor = 1
                          else S.Cursor = S.Cursor'Old + 1),
      Global => (In_Out => (Client,
                            Gneiss_Internal.Platform_State));

   procedure Flush (S : in out Server_Slot) with
      Pre  => Log.Initialized (Client),
      Post => Log.Initialized (Client) and then S.Cursor = 0,
      Global => (In_Out => (Client,
                            Gneiss_Internal.Platform_State));

   package Log_Client is new Log.Client;
   package Log_Server is new Log.Server (Server_Meta, Write, Initialize, Finalize, Ready);
   package Log_Dispatcher is new Log.Dispatcher (Log_Server, Dispatch);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Dispatcher.Initialize (Dispatcher, Cap);
      Log_Client.Initialize (Client, Capability, "lolcat");
      if
         Log.Initialized (Dispatcher)
         and then Log.Initialized (Client)
      then
            Log_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Write (Session : in out Log.Server_Session;
                    Data    :        String)
   is
      use type Gneiss.Session_Index;
      I : constant Gneiss.Session_Index_Option := Log.Index (Session);
   begin
      if
         not Log.Initialized (Client)
         or else I.Value not in Server_Data'Range
      then
         return;
      end if;
      Put (Server_Data (I.Value), '[');
      for J in 1 .. Server_Data (I.Value).Last loop
         pragma Loop_Invariant (I.Value = I.Value'Loop_Entry);
         pragma Loop_Invariant (Log.Initialized (Client));
         pragma Loop_Invariant (I.Value in Server_Data'Range);
         Put (Server_Data (I.Value),
              Server_Data (I.Value).Ident (J));
      end loop;
      Put (Server_Data (I.Value), ']');
      Put (Server_Data (I.Value), ' ');
      for Char of Data loop
         pragma Loop_Invariant (Log.Initialized (Client));
         Put_Color (Server_Data (I.Value), Char);
      end loop;
      Flush (Server_Data (I.Value));
   end;

   procedure Destruct
   is
   begin
      Log_Client.Finalize (Client);
   end Destruct;

   procedure Initialize (Session : in out Log.Server_Session;
                         Context : in out Server_Meta)
   is
      Index : constant Gneiss.Session_Index := Log.Index (Session).Value;
   begin
      if Index in Context'Range then
         Context (Index).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Log.Server_Session;
                       Context : in out Server_Meta)
   is
      Index : constant Gneiss.Session_Index := Log.Index (Session).Value;
   begin
      if Index in Context'Range then
         Context (Log.Index (Session).Value).Ready := False;
      end if;
   end Finalize;

   procedure Dispatch (Session : in out Log.Dispatcher_Session;
                       Cap     :        Log.Dispatcher_Capability;
                       Name    :        String;
                       Label   :        String)
   is
   begin
      if Log_Dispatcher.Valid_Session_Request (Session, Cap) then
         for I in Servers'Range loop
            pragma Loop_Invariant (Log.Initialized (Session));
            pragma Loop_Invariant (Log.Registered (Session));
            if
               not Ready (Servers (I), Server_Data)
               and then not Log.Initialized (Servers (I))
               and then Name'Length <= Server_Data (I).Ident'Last
               and then Label'Length <= Server_Data (I).Ident'Last
               and then Name'Length + Label'Length + 1 <= Server_Data (I).Ident'Last
               and then Name'First < Positive'Last - Server_Data (I).Ident'Last
            then
               Log_Dispatcher.Session_Initialize (Session, Cap, Servers (I), Server_Data, I);
               if Ready (Servers (I), Server_Data) and then Log.Initialized (Servers (I)) then
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

   function Ready (Session : Log.Server_Session;
                   Context : Server_Meta) return Boolean is
      (if
          Log.Index (Session).Valid
          and then Log.Index (Session).Value in Context'Range
       then Context (Log.Index (Session).Value).Ready
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
            -- WORKAROUND: Componolit/Workarounds#25
            Clr : constant String := Get_Color (S.Hue);
         begin
            for H of Clr loop
               pragma Loop_Invariant (Log.Initialized (Client));
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
      Log_Client.Print (Client, S.Buffer (1 .. S.Cursor));
      Log_Client.Flush (Client);
      S.Cursor  := 0;
      S.Flushed := True;
   end Flush;

end Component;
