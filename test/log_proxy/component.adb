
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
   end record;

   Color_Red     : constant String := Character'Val (8#33#) & "[31m";
   Color_Orange  : constant String := Character'Val (8#33#) & "[91m";
   Color_Yellow  : constant String := Character'Val (8#33#) & "[33m";
   Color_Green   : constant String := Character'Val (8#33#) & "[32m";
   Color_Cyan    : constant String := Character'Val (8#33#) & "[36m";
   Color_Blue    : constant String := Character'Val (8#33#) & "[34m";
   Color_Magenta : constant String := Character'Val (8#33#) & "[35m";
   Reset         : constant String := Character'Val (8#33#) & "[0m";

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

   type Server_Reg is array (Gneiss.Session_Index range <>) of Gneiss.Log.Server_Session;
   type Server_Meta is array (Gneiss.Session_Index range <>) of Server_Slot;

   procedure Write (Session : in out Gneiss.Log.Server_Session;
                    Data    :        String);
   procedure Initialize (Session : in out Gneiss.Log.Server_Session);
   procedure Finalize (Session : in out Gneiss.Log.Server_Session);
   function Ready (Session : Gneiss.Log.Server_Session) return Boolean;
   procedure Dispatch (Session : in out Gneiss.Log.Dispatcher_Session;
                       Cap     :        Gneiss.Log.Dispatcher_Capability;
                       Name    :        String;
                       Label   :        String);

   procedure Put_Color (S : in out Server_Slot;
                        C :        Character);

   procedure Put (S : in out Server_Slot;
                  C :        Character);

   procedure Flush (S : in out Server_Slot);

   package Log_Server is new Gneiss.Log.Server (Write, Initialize, Finalize, Ready);
   package Log_Dispatcher is new Gneiss.Log.Dispatcher (Log_Server, Dispatch);

   Dispatcher  : Gneiss.Log.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg (1 .. 2);
   Server_Data : Server_Meta (Servers'Range);
   Client      : Gneiss.Log.Client_Session;

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
      I : constant Gneiss.Session_Index_Option := Gneiss.Log.Index (Session);
   begin
      if
         not Gneiss.Log.Initialized (Client)
         or else I.Value not in Server_Data'Range
      then
         return;
      end if;
      Put (Server_Data (I.Value), '[');
      for C of Server_Data (I.Value).Ident (1 .. Server_Data (I.Value).Last) loop
         Put (Server_Data (I.Value), C);
      end loop;
      Put (Server_Data (I.Value), ']');
      Put (Server_Data (I.Value), ' ');
      for Char of Data loop
         Put_Color (Server_Data (I.Value), Char);
      end loop;
      Flush (Server_Data (I.Value));
   end;

   procedure Destruct
   is
   begin
      Gneiss.Log.Client.Finalize (Client);
   end Destruct;

   procedure Initialize (Session : in out Gneiss.Log.Server_Session)
   is
      Index : constant Gneiss.Session_Index := Gneiss.Log.Index (Session).Value;
   begin
      if Index in Server_Data'Range then
         Server_Data (Index).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Gneiss.Log.Server_Session)
   is
      Index : constant Gneiss.Session_Index := Gneiss.Log.Index (Session).Value;
   begin
      if Index in Server_Data'Range then
         Server_Data (Index).Ready := False;
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
            if not Ready (Servers (I)) then
               Log_Dispatcher.Session_Initialize (Session, Cap, Servers (I), I);
               if Ready (Servers (I)) and then Gneiss.Log.Initialized (Servers (I)) then
                  Server_Data (I).Last := Name'Length + Label'Length + 1;
                  Server_Data (I).Ident (1 .. Server_Data (I).Last) := Name & ":" & Label;
                  Log_Dispatcher.Session_Accept (Session, Cap, Servers (I));
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Log_Dispatcher.Session_Cleanup (Session, Cap, S);
      end loop;
   end Dispatch;

   function Ready (Session : Gneiss.Log.Server_Session) return Boolean is
      (if
          Gneiss.Log.Index (Session).Valid
          and then Gneiss.Log.Index (Session).Value in Server_Data'Range
       then Server_Data (Gneiss.Log.Index (Session).Value).Ready
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
         for H of Get_Color (S.Hue) loop
            Put (S, H);
         end loop;
         Put (S, C);
         S.Hue := Rainbow (S.Hue);
      end if;
   end Put_Color;

   procedure Put (S : in out Server_Slot;
                  C :        Character)
   is
   begin
      S.Cursor := S.Cursor + 1;
      S.Buffer (S.Cursor) := C;
      if S.Cursor = S.Buffer'Last - 4 then
         Flush (S);
      end if;
   end Put;

   procedure Flush (S : in out Server_Slot)
   is
   begin
      S.Buffer (S.Cursor + 1 .. S.Cursor + 4) := Reset;
      Gneiss.Log.Client.Print (Client, S.Buffer (1 .. S.Cursor));
      Gneiss.Log.Client.Flush (Client);
      S.Cursor := 0;
      S.Flushed := True;
   end Flush;

end Component;
