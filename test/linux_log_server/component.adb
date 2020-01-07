
with Gneiss.Log;
with Gneiss.Log.Server;
with Gneiss.Log.Dispatcher;

package body Component with
   SPARK_Mode
is

   type Server_Slot is record
      Ident : String (1 .. 513) := (others => ASCII.NUL);
      Ready : Boolean           := False;
   end record;

   type Server_Reg is array (Gneiss.Session_Index range <>) of Gneiss.Log.Server_Session;
   type Server_Meta is array (Gneiss.Session_Index range <>) of Server_Slot;

   procedure Event;
   procedure Initialize (Session : in out Gneiss.Log.Server_Session);
   procedure Finalize (Session : in out Gneiss.Log.Server_Session);
   function Ready (Session : Gneiss.Log.Server_Session) return Boolean;
   procedure Dispatch (Session : in out Gneiss.Log.Dispatcher_Session;
                       Cap     :        Gneiss.Log.Dispatcher_Capability;
                       Name    :        String;
                       Label   :        String);

   package Log_Server is new Gneiss.Log.Server (Event, Initialize, Finalize, Ready);
   package Log_Dispatcher is new Gneiss.Log.Dispatcher (Log_Server, Dispatch);

   Dispatcher  : Gneiss.Log.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg (1 .. 10);
   Server_Data : Server_Meta (Servers'Range);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Dispatcher.Initialize (Dispatcher, Cap);
      if Gneiss.Log.Initialized (Dispatcher) then
         Log_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
      procedure Put (C : Character) with
         Import,
         Convention    => C,
         External_Name => "put";
      Char : Character;
   begin
      for Server of Servers loop
         if Gneiss.Log.Initialized (Server) then
            while Log_Server.Available (Server) loop
               Log_Server.Get (Server, Char);
               Put (Char);
            end loop;
         end if;
      end loop;
   end Event;

   procedure Destruct
   is
   begin
      null;
   end Destruct;

   procedure Initialize (Session : in out Gneiss.Log.Server_Session)
   is
   begin
      if Gneiss.Log.Index (Session) in Server_Data'Range then
         Server_Data (Gneiss.Log.Index (Session)).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Gneiss.Log.Server_Session)
   is
   begin
      if Gneiss.Log.Index (Session) in Server_Data'Range then
         Server_Data (Gneiss.Log.Index (Session)).Ready := False;
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
                  Server_Data (I).Ident (1 .. Name'Length + Label'Length + 1) := Name & ":" & Label;
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
      (if Gneiss.Log.Index (Session) in Server_Data'Range
       then Server_Data (Gneiss.Log.Index (Session)).Ready
       else False);

end Component;
